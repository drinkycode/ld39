package com.ludoko.ld39;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Layer extends FlxGroup
{
	
	public var order:Int;

	public function new(Order:Int) 
	{
		super();
		order = Order;
	}
	
}