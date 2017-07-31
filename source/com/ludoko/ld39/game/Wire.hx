package com.ludoko.ld39.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Michael Lee
 */
class Wire extends TileObject
{
	
	public static var group:FlxGroup;
	
	public static function preload(Amount:Int):FlxGroup
	{
		if (group == null)
		{
			group = new FlxGroup();
		}
		
		for (i in 0 ... Amount)
		{
			createInstance();
		}
		
		return group;
	}
	
	private static function createInstance():Wire
	{
		var o:Wire = new Wire();
		o.kill();
		group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float):Wire
	{
		var o:Wire = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.reset(X, Y);
		return o;
	}
	
	
	public static inline var HITBOX_WIDTH:Int = 48;
	public static inline var HITBOX_HEIGHT:Int = 48;
	
	private var _currentAnimation:String;
	private var _hurtTimer:Float = 0;
	
	public function new() 
	{
		super();
		loadGraphic("assets/images/wire.png", true, 48, 48);
		animation.add("horizontal", 	[0], 0, false);
		animation.add("vertical", 		[1], 0, false);
		animation.add("corner_nw", 		[2], 0, false);
		animation.add("corner_ne", 		[3], 0, false);
		animation.add("corner_se", 		[4], 0, false);
		animation.add("corner_sw", 		[5], 0, false);
		animation.add("three_nwe", 		[6], 0, false);
		animation.add("three_nse", 		[7], 0, false);
		animation.add("three_sew", 		[8], 0, false);
		animation.add("three_nsw", 		[9], 0, false);
		animation.add("all", 			[10], 0, false);
		
		animation.add("horizontal_l", 	[11], 0, false);
		animation.add("vertical_l", 	[12], 0, false);
		animation.add("corner_nw_l", 	[13], 0, false);
		animation.add("corner_ne_l", 	[14], 0, false);
		animation.add("corner_se_l", 	[15], 0, false);
		animation.add("corner_sw_l", 	[16], 0, false);
		animation.add("three_nwe_l", 	[17], 0, false);
		animation.add("three_nse_l", 	[18], 0, false);
		animation.add("three_sew_l", 	[19], 0, false);
		animation.add("three_nsw_l", 	[20], 0, false);
		animation.add("all_l", 			[21], 0, false);
		
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
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		tileX = GameLevel.clampTileX(GameLevel.tileAtX(X));
		tileY = GameLevel.clampTileY(GameLevel.tileAtY(Y));
		
		super.reset(GameLevel.positionAtTileX(tileX), GameLevel.positionAtTileY(tileY));
		
		PlayState.instance.checkWireConnections();
		PlayState.instance.currentLevel.addGameObjectToLayer(this, tileY);
		
		_hurtTimer = 0;
		health = 3;
	}
	
	public function updateWireConnection(WireConnections:Array<Array<Int>>):Void
	{
		var connections:Int = 0;
		var connectedN:Bool = false;
		var connectedE:Bool = false;
		var connectedS:Bool = false;
		var connectedW:Bool = false;
		
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
		
		var lit:Bool = false;
		
		for (i in 0 ... Generator.group.members.length)
		{
			if (!Generator.group.members[i].alive) continue;
			
			var generator:Generator = cast Generator.group.members[i];
			if (WireConnections[tileY][tileX] == WireConnections[generator.tileY][generator.tileX])
			{
				lit = true;
				break;
			}
		}
		
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
	
	private function playAnimation(Animation:String, Lit:Bool = false):Void
	{
		_currentAnimation = Animation;
		if (!Lit)
		{
			animation.play(Animation);
		}
		else
		{
			animation.play(Animation + "_l");
		}
	}
	
	override public function update():Void 
	{
		super.update();
		_hurtTimer -= FlxG.elapsed;
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0) return;
		super.hurt(Damage);
		_hurtTimer = 3;
		
		if (health <= 0)
		{
			PlayState.instance.checkWireConnections(false);
		}
		else
		{
			FlxSpriteUtil.flicker(this, 1);
		}
	}
	
}