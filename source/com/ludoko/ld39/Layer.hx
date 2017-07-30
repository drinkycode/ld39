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
	
	public var row:Int;
	
	public var gameObjects:FlxGroup;
	public var characters:FlxGroup;
	
	public function new(Row:Int) 
	{
		super();
		row = Row;
		
		gameObjects = new FlxGroup();
		add(gameObjects);
		
		characters = new FlxGroup();
		add(characters);
	}
	
}