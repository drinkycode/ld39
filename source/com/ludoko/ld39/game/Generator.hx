package com.ludoko.ld39.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Generator extends FlxSprite
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
	
	private static function createInstance():Generator
	{
		var o:Generator = new Generator();
		o.kill();
		group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float):Generator
	{
		var o:Generator = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.reset(X, Y);
		return o;
	}
	
	public function new() 
	{
		super( -9999, -9999);
		loadGraphic("assets/images/generator.png");
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
	}
	
}