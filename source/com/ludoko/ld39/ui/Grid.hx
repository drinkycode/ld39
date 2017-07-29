package com.ludoko.ld39.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Grid extends FlxGroup
{

	public static inline var GRID_WIDTH:Int 	= 48;
	public static inline var GRID_HEIGHT:Int 	= 48;
	
	public var gridWidth:Int;
	public var gridHeight:Int;
	
	public function new(Width:Int, Height:Int) 
	{
		super();
		
		setupGrid(Width, Height);
	}
	
	public function setupGrid(Width:Int, Height:Int):Void
	{
		gridWidth = Width;
		gridHeight = Height;
		
		var startingOffsetX:Float = Math.floor((FlxG.width - (Width * GRID_WIDTH)) * 0.5);
		var startingOffsetY:Float = Math.floor((FlxG.height - (Height * GRID_HEIGHT)) * 0.5);
		
		for (i in 0 ... gridWidth)
		{
			for (j in 0 ... gridHeight)
			{
				var tile:FlxSprite = new FlxSprite(i * GRID_WIDTH + startingOffsetX, j * GRID_HEIGHT + startingOffsetY, "assets/images/grid.png");
				add(tile);
			}
		}
	}
	
}