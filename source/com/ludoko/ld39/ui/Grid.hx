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

	public function new(Width:Int, Height:Int) 
	{
		super();
		
		for (i in 0 ... Width)
		{
			for (j in 0 ... Height)
			{
				var tile:FlxSprite = new FlxSprite(GameLevel.getPositionAtTileX(i), GameLevel.getPositionAtTileY(j), "assets/images/grid.png");
				add(tile);
			}
		}
	}
	
}