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
	
	public var power:FlxText;
	
	public function new() 
	{
		super();
		
		power = new FlxText(10, 10, FlxG.width, "Power: 0");
		power.setFormat(FONT_DEFINITELY, 32, 0x000000);
		add(power);
	}
	
	public function updatePower(Power:Float):Void
	{
		power.text = "Total Power: " + Power;
	}
	
}