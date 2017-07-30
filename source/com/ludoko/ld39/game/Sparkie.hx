package com.ludoko.ld39.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;

/**
 * ...
 * @author Michael Lee
 */
class Sparkie extends TileObject
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
	
	private static function createInstance():Sparkie
	{
		var o:Sparkie = new Sparkie();
		o.kill();
		group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float):Sparkie
	{
		var o:Sparkie = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.reset(X, Y);
		return o;
	}
	
	
	
	public static inline var ENEMY_SPEED:Float = 60;
	
	public static inline var ENEMY_WIDTH:Int = 32;
	public static inline var ENEMY_HEIGHT:Int = 32;
	
	public var state:Int = 0;
	public var timer:Float = 0;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/sparkie.png");
		
		// Set up hitbox
		width = ENEMY_WIDTH;
		height = ENEMY_HEIGHT;
		offset.x = Math.floor((frameWidth - width) * 0.5);
		offset.y = Math.floor((frameHeight - height) * 0.5);
	}
	
	override public function kill():Void 
	{
		super.kill();
		if (PlayState.instance.currentLevel != null)
		{
			PlayState.instance.currentLevel.removeCharacterFromLayer(this, tileY);
		}
	}
	
	public function setCenteredPosition(X:Float, Y:Float):Void
	{
		x = X - ENEMY_WIDTH * 0.5;
		y = Y - ENEMY_HEIGHT * 0.5;
		
		tileY = previousTileY = GameLevel.tileAtY(Y);
		PlayState.instance.currentLevel.addCharacterToLayer(this, tileY);
	}
	
	public var centerX(get, null):Float;
	public function get_centerX():Float
	{
		return x + ENEMY_WIDTH * 0.5;
	}
	
	public var centerY(get, null):Float;
	public function get_centerY():Float
	{
		return y + ENEMY_HEIGHT * 0.5;
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(-9999, -99999);
		setCenteredPosition(X, Y);
		
		timer = FlxRandom.floatRanged(1, 3);
	}
	
	override public function update():Void 
	{
		var previousY:Float = y;
		
		if (state == 0)
		{
			velocity.x = velocity.y = 0;
			
			timer -= FlxG.elapsed;
			if (timer <= 0)
			{
				state = 1;
				timer = FlxRandom.floatRanged(3, 6);
			}
		}
		else
		{
			if (((velocity.x == 0) && (velocity.y == 0)) || (FlxRandom.float() < 0.2))
			{
				var angle:Float = Math.atan2((PlayState.instance.player.centerY - centerY), (PlayState.instance.player.centerX - centerX));
				velocity.x = Math.cos(angle) * ENEMY_SPEED;
				velocity.y = Math.sin(angle) * ENEMY_SPEED;
			}
			
			timer -= FlxG.elapsed;
			if (timer <= 0)
			{
				state = 0;
				timer = FlxRandom.floatRanged(1, 3);
			}
		}
		
		super.update();
		
		FlxG.collide(this, Wall.group);
		FlxG.collide(this, Generator.group);
		
		if ((y != previousY))
		{
			var newTileY:Int = GameLevel.tileAtY(y + ENEMY_HEIGHT * 0.5);
			if (previousTileY != newTileY)
			{
				if (PlayState.instance.currentLevel.removeCharacterFromLayer(this, previousTileY))
				{
					PlayState.instance.currentLevel.addCharacterToLayer(this, newTileY);
					previousTileY = newTileY;
				}
			}
		}
	}
	
}