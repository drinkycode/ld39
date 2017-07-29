package com.ludoko.ld39.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Enemy extends FlxSprite
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
	
	private static function createInstance():Enemy
	{
		var o:Enemy = new Enemy();
		o.kill();
		group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float):Enemy
	{
		var o:Enemy = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.reset(X, Y);
		return o;
	}
	
	public function new() 
	{
		super(-9999, -9999);
	}
	
}