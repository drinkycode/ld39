package com.ludoko.ld39.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Wire extends FlxSprite
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
	
	
	public static inline var HITBOX_WIDTH:Int = 64;
	public static inline var HITBOX_HEIGHT:Int = 64;
	
	public function new() 
	{
		super( -9999, -9999);
		loadGraphic("assets/images/wire.png");
		
		width = HITBOX_WIDTH;
		height = HITBOX_HEIGHT;
		centerOffsets();
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		var createAtX:Float = X;
		var createAtY:Float = Y;
		
		super.reset(createAtX - HITBOX_WIDTH * 0.5, createAtY - HITBOX_HEIGHT * 0.5);
	}
	
}