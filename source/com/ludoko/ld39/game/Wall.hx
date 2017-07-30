package com.ludoko.ld39.game;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Wall extends FlxObject
{

	public static var group:FlxGroup;
	
	public static function preload():FlxGroup
	{
		if (group == null)
		{
			group = new FlxGroup();
		}
		return group;
	}
	
	public function new(X:Float, Y:Float, Width:Int, Height:Int) 
	{
		super(X, Y, Width, Height);
		immovable = true;
	}
	
}