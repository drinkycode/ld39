package com.ludoko.ld39.game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Michael Lee
 */
class Wire extends TileObject
{
	
	public static var _group:FlxGroup;
	public static var _map:Map<String, Wire>;
	
	public static function preload(Amount:Int, Force:Bool = false):FlxGroup
	{
		if (Force || (_group == null))
		{
			_group = new FlxGroup();
			_map = new Map<String, Wire>();
		}
		
		for (i in 0 ... Amount)
		{
			createInstance();
		}
		
		return _group;
	}
	
	private static function createInstance():Wire
	{
		var o:Wire = new Wire();
		o.kill();
		_group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float):Wire
	{
		var o:Wire = cast _group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.reset(X, Y);
		return o;
	}
	
	public static function setDepths()
	{
		if (Generator._group != null)
		{
			for (wire in _map)
			{
				wire.depth = 0;
			}
			for (i in 0 ... Generator._group.members.length)
			{
				var generator:Generator = cast Generator._group.members[i];
				if (!generator.alive) continue;
				var gx:Int = generator.tileX;
				var gy:Int = generator.tileY;
				var d:Int = generator.sourceDepth + 1;
				if (generator.startingPower == 100)
				{
					d = 1;
				}
				else if (d <= 0 || d > 5)
				{
					d = 5;
				}
				//trace(i + ": " + d);
				setDepthGen(gx, gy - 1, d, FlxObject.DOWN);
				setDepthGen(gx, gy + 1, d, FlxObject.UP);
				setDepthGen(gx - 1, gy, d, FlxObject.RIGHT);
				setDepthGen(gx + 1, gy, d, FlxObject.LEFT);
			}
			for (wire in _map)
			{
				wire.playAnimation(null, wire.depth);
			}
		}
	}
	private static function setDepthGen(TileX:Int, TileY:Int, Depth:Int, Dir:Int = FlxObject.NONE, Priority:Int = 1)
	{
		if (_map.exists(TileX + "," + TileY))
		{ 
			var wire:Wire = _map.get(TileX + "," + TileY);
			if (wire.priority > 0)
			{
				return;
			}
			
			wire.depth = Depth;
			wire.priority = Priority + 1;
			//trace(wire.tileX + "," + wire.tileY + ": " + wire.priority);
			if (Dir != FlxObject.UP)
			{
				setDepthGen(TileX, TileY - 1, Depth, FlxObject.DOWN, wire.priority);
			}
			if (Dir != FlxObject.DOWN)
			{
				setDepthGen(TileX, TileY + 1, Depth, FlxObject.UP, wire.priority);
			}
			if (Dir != FlxObject.LEFT)
			{
				setDepthGen(TileX - 1, TileY, Depth, FlxObject.RIGHT, wire.priority);
			}
			if (Dir != FlxObject.RIGHT)
			{
				setDepthGen(TileX + 1, TileY, Depth, FlxObject.LEFT, wire.priority);
			}
			
			wire.priority = 0;
		}
	}
	
	public static inline var HITBOX_WIDTH:Int = 48;
	public static inline var HITBOX_HEIGHT:Int = 48;
	
	private var _currentAnimation:String = "horizontal";
	private var _hurtTimer:Float = 0;
	
	public var depth:Int = 0;
	public var priority:Int = 0;
	
	public function new() 
	{
		super();
		loadGraphic("assets/images/wire.png", true, 48, 48);
		for (i in 0...6)
		{
			animation.add("horizontal"+i, 	[0+15*i], 0, false);
			animation.add("vertical"+i, 	[1+15*i], 0, false);
			animation.add("corner_nw"+i, 	[2+15*i], 0, false);
			animation.add("corner_ne"+i, 	[3+15*i], 0, false);
			animation.add("corner_se"+i, 	[4+15*i], 0, false);
			animation.add("corner_sw"+i, 	[5+15*i], 0, false);
			animation.add("three_nwe"+i, 	[6+15*i], 0, false);
			animation.add("three_nse"+i, 	[7+15*i], 0, false);
			animation.add("three_sew"+i, 	[8+15*i], 0, false);
			animation.add("three_nsw"+i, 	[9+15*i], 0, false);
			animation.add("all"+i, 			[10+15*i], 0, false);
			animation.add("die"+i, 			[11+15*i, 12+15*i, 13+15*i, 14+15*i], 15, false);
		}
		
		immovable = true;
		
		width = HITBOX_WIDTH;
		height = HITBOX_HEIGHT;
		centerOffsets();
	}
	
	override public function kill():Void
	{
		super.kill();
		if (PlayState.instance.currentLevel != null)
		{
			PlayState.instance.currentLevel.removeGameObjectFromLayer(this, tileY);
		}
		_map.remove(tileX + "," + tileY);
		
	}
	
	public function die():Void 
	{
		alive = false;
		playAnimation("die", depth);
		_map.remove(tileX + "," + tileY);
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		tileX = GameLevel.clampTileX(GameLevel.tileAtX(X));
		tileY = GameLevel.clampTileY(GameLevel.tileAtY(Y));
		_map.set(tileX + "," + tileY, this);
		
		super.reset(GameLevel.positionAtTileX(tileX), GameLevel.positionAtTileY(tileY));
		
		PlayState.instance.checkWireConnections();
		PlayState.instance.currentLevel.addGameObjectToLayer(this, tileY);
		
		_hurtTimer = 0;
		health = 2;
		alive = true;
	}
	
	public function updateWireConnection(WireConnections:Array<Array<Int>>):Void
	{
		var connections:Int = 0;
		var connectedN:Bool = false;
		var connectedE:Bool = false;
		var connectedS:Bool = false;
		var connectedW:Bool = false;
		
		var lit:Int = 0;
		
		if ((tileY > 0) && (WireConnections[tileY - 1][tileX] != 0))
		{
			connectedN = true;
			connections++;
		}
		if ((tileX < GameLevel.levelWidth - 1) && (WireConnections[tileY][tileX + 1] != 0))
		{
			connectedE = true;
			connections++;
		}
		if ((tileY < GameLevel.levelHeight - 1) && (WireConnections[tileY + 1][tileX] != 0))
		{
			connectedS = true;
			connections++;
		}
		if ((tileX > 0) && (WireConnections[tileY][tileX - 1] != 0))
		{
			connectedW = true;
			connections++;
		}
		
		lit = depth;
		
		if (connections == 4)
		{
			playAnimation("all", lit);
		}
		else if (connections == 3)
		{
			if (connectedN && connectedS && connectedW)
			{
				playAnimation("three_nsw", lit);
			}
			else if (connectedN && connectedS && connectedE)
			{
				playAnimation("three_nse", lit);
			}
			else if (connectedS && connectedE && connectedW)
			{
				playAnimation("three_sew", lit);
			}
			else 
			{
				playAnimation("three_nwe", lit);
			}
		}
		else if (connections == 2)
		{
			if (connectedN && connectedW)
			{
				playAnimation("corner_nw", lit);
			}
			else if (connectedN && connectedE)
			{
				playAnimation("corner_ne", lit);
			}
			else if (connectedS && connectedE)
			{
				playAnimation("corner_se", lit);
			}
			else if (connectedS && connectedW)
			{
				playAnimation("corner_sw", lit);
			}
			else if (connectedN && connectedS)
			{
				playAnimation("vertical", lit);
			}
			else
			{
				playAnimation("horizontal", lit);
			}
		}
		else
		{
			if (connectedN || connectedS)
			{
				playAnimation("vertical", lit);
			}
			else
			{
				playAnimation("horizontal", lit);
			}
		}
	}
	
	private function playAnimation(Animation:String, Lit:Int = 0):Void
	{
		if (Animation != null)
		{
			_currentAnimation = Animation;
		}
		animation.play(_currentAnimation + Lit);
		depth = Lit;
	}
	
	override public function update():Void 
	{
		super.update();
		_hurtTimer -= FlxG.elapsed;
		
		if (!alive && animation.finished && exists)
		{
			if (PlayState.instance.currentLevel != null)
			{
				PlayState.instance.currentLevel.removeGameObjectFromLayer(this, tileY);
			}
			exists = false;
		}
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0) return;
		health = health - Damage;
		if (health <= 0)
		{
			die();
		}
		_hurtTimer = 2;
		
		if (health <= 0)
		{
			PlayState.instance.checkWireConnections(false);
			SoundUtil.play("wire_die");
		}
		else
		{
			SoundUtil.play("wire_hurt");
			FlxSpriteUtil.flicker(this, 1);
		}
	}
	
}