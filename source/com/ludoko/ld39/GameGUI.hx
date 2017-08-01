package com.ludoko.ld39;

import com.ludoko.ld39.ui.LevelComplete;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

/**
 * ...
 * @author Michael Lee
 */
class GameGUI extends FlxGroup
{

	public static inline var FONT_TILLANA:String = "assets/fonts/Tillana-ExtraBold.ttf";
	
	public var health:FlxText;
	public var level:FlxText;
	public var levelComplete:LevelComplete;
	
	public function new() 
	{
		super();
		
		health = new FlxText(8, 6, FlxG.width, "Health: 3");
		health.setFormat(FONT_TILLANA, 24, 0x000000);
		add(health);
		
		level = new FlxText(8, FlxG.height - 39, FlxG.width, "Level: 1");
		level.setFormat(FONT_TILLANA, 24, 0x000000);
		add(level);
		
		levelComplete = new LevelComplete();
		add(levelComplete);
	}
	
	public function updateHealth(Health:Int):Void
	{
		health.text = "Health: " + Health;
	}
	
	public function updateLevel(Level:Int):Void
	{
		level.text = "Level: " + Level;
	}
	
}