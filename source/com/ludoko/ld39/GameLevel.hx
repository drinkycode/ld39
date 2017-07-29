package com.ludoko.ld39;

import com.ludoko.ld39.ui.Grid;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class GameLevel extends FlxGroup
{

	public static function getTilePixelAtX(X:Float):Int
	{
		return 0;
	}
	
	
	public var levelWidth:Int;
	public var levelHeight:Int;
	
	public var layers:Array<Layer>;
	
	public var grid:Grid;
	
	public function new(LevelWidth:Int, LevelHeight:Int) 
	{
		super();
		
		levelWidth = LevelWidth;
		levelHeight = LevelHeight;
		
		
		// Currently just a debug grid.
		grid = new Grid(levelWidth, levelHeight);
		add(grid);
		
		
		layers = new Array<Layer>();
		
		var i:Int = levelHeight - 1;
		while(i >= 0)
		{
			var layer:Layer = new Layer(i);
			add(layer);
			i--;
		}
	}
	
}