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
	
	private var _hurtTimer:Float = 0;
	
	public function new() 
	{
		super();
		loadGraphic("assets/images/wire.png", true, 48, 48);
		animation.add("horizontal", [0], 0, false);
		animation.add("vertical", [1], 0, false);
		animation.add("corner_nw", [2], 0, false);
		animation.add("corner_ne", [3], 0, false);
		animation.add("corner_se", [4], 0, false);
		animation.add("corner_sw", [5], 0, false);
		animation.add("three_nwe", [6], 0, false);
		animation.add("three_nse", [7], 0, false);
		animation.add("three_sew", [8], 0, false);
		animation.add("three_nsw", [9], 0, false);
		animation.add("all", [10], 0, false);
		
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
		
		if ((tileY > 0) && (WireConnections[tileY - 1][tileX] == 1))
		{
			connectedN = true;
			connections++;
		}
		if ((tileX < GameLevel.levelWidth - 1) && (WireConnections[tileY][tileX + 1] == 1))
		{
			connectedE = true;
			connections++;
		}
		if ((tileY < GameLevel.levelHeight - 1) && (WireConnections[tileY + 1][tileX] == 1))
		{
			connectedS = true;
			connections++;
		}
		if ((tileX > 0) && (WireConnections[tileY][tileX - 1] == 1))
		{
			connectedW = true;
			connections++;
		}
		
		if (connections == 4)
		{
			animation.play("all");
		}
		else if (connections == 3)
		{
			if (connectedN && connectedS && connectedW)
			{
				animation.play("three_nsw");
			}
			else if (connectedN && connectedS && connectedE)
			{
				animation.play("three_nse");
			}
			else if (connectedS && connectedE && connectedW)
			{
				animation.play("three_sew");
			}
			else 
			{
				animation.play("three_nwe");
			}
		}
		else if (connections == 2)
		{
			if (connectedN && connectedW)
			{
				animation.play("corner_nw");
			}
			else if (connectedN && connectedE)
			{
				animation.play("corner_ne");
			}
			else if (connectedS && connectedE)
			{
				animation.play("corner_se");
			}
			else if (connectedS && connectedW)
			{
				animation.play("corner_sw");
			}
			else if (connectedN && connectedS)
			{
				animation.play("vertical");
			}
			else
			{
				animation.play("horizontal");
			}
		}
		else
		{
			if (connectedN || connectedS)
			{
				animation.play("vertical");
			}
			else
			{
				animation.play("horizontal");
			}
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