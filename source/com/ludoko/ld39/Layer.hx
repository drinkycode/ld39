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
	public var ui:FlxGroup;
	
	public function new(Row:Int) 
	{
		super();
		row = Row;
		
		gameObjects = new FlxGroup();
		add(gameObjects);
		
		characters = new FlxGroup();
		add(characters);
		
		ui = new FlxGroup();
		add(ui);
	}
	
	public function addGameObject(Object:FlxObject):Void
	{
		gameObjects.add(Object);
	}
	
	public function removeGameObject(Object:FlxObject):Bool
	{
		if (gameObjects.members.indexOf(Object) == -1) return false;
		gameObjects.remove(Object);
		return true;
	}
	
	public function addCharacter(Object:FlxObject):Void
	{
		characters.add(Object);
	}
	
	public function removeCharacter(Object:FlxObject):Bool
	{
		if (characters.members.indexOf(Object) == -1) return false;
		characters.remove(Object);
		return true;
	}
	
	public function addUI(Object:FlxObject):Void
	{
		ui.add(Object);
	}

	public function removeUI(Object:FlxObject):Bool
	{
		if (ui.members.indexOf(Object) == -1) return false;
		ui.remove(Object);
		return true;
	}
	
}