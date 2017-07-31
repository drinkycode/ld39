package com.ludoko.ld39;

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

	public static inline var FONT_04B03B:String = "assets/fonts/04B_03B.TTF";
	public static inline var FONT_DEFINITELY:String = "assets/fonts/definitely_possible.ttf";
	public static inline var FONT_TILLANA:String = "assets/fonts/Tillana-ExtraBold.ttf";
	
	public var level:FlxText;
	
	public function new() 
	{
		super();
		
		level = new FlxText(8, FlxG.height - 39, FlxG.width, "Level: 1");
		level.setFormat(FONT_TILLANA, 24, 0x000000);
		add(level);
	}
	
	public function updateLevel(Level:Int):Void
	{
		level.text = "Level: " + Level;
	}
	
}