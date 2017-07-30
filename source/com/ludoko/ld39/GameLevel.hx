package com.ludoko.ld39;

import com.ludoko.ld39.game.Wall;
import com.ludoko.ld39.ui.Grid;

import flixel.FlxG;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class GameLevel extends FlxGroup
{
	
	public static inline var TILE_WIDTH:Int 	= 48;
	public static inline var TILE_HEIGHT:Int 	= 48;
	
	public static var tilePixelOffsetX:Int;
	public static var tilePixelOffsetY:Int;

	public static function findTilePositionAtX(X:Float)
	{
		return getPositionAtTileX(getTileAtX(X));
	}
	
	public static function findTilePositionAtY(Y:Float)
	{
		return getPositionAtTileY(getTileAtY(Y));
	}
	
	public static function getPositionAtTileX(TileX:Int):Int
	{
		return TileX * GameLevel.TILE_WIDTH + GameLevel.tilePixelOffsetX;
	}
	
	public static function getPositionAtTileY(TileY:Int):Int
	{
		return TileY * GameLevel.TILE_HEIGHT + GameLevel.tilePixelOffsetY;
	}
	
	public static function getTileAtX(X:Float):Int
	{
		return Math.floor((X - GameLevel.tilePixelOffsetX) / TILE_WIDTH);
	}
	
	public static function getTileAtY(Y:Float):Int
	{
		return Math.floor((Y - GameLevel.tilePixelOffsetY) / TILE_HEIGHT);
	}
	
	
	
	public static var wallSize:Int = 32;
	
	public var levelWidth:Int;
	public var levelHeight:Int;
	
	public var layers:Array<Layer>;
	
	public var grid:Grid;
	
	public function new(LevelWidth:Int, LevelHeight:Int) 
	{
		super();
		
		levelWidth = LevelWidth;
		levelHeight = LevelHeight;
		
		tilePixelOffsetX = Math.floor((FlxG.width - (levelWidth * TILE_WIDTH)) * 0.5);
		tilePixelOffsetY = Math.floor((FlxG.height - (levelHeight* TILE_HEIGHT)) * 0.5);
		
		
		// Currently just a debug grid.
		grid = new Grid(levelWidth, levelHeight);
		add(grid);
		
		setupWalls();
		
		layers = new Array<Layer>();
		
		var i:Int = levelHeight - 1;
		while(i >= 0)
		{
			var layer:Layer = new Layer(i);
			add(layer);
			i--;
		}
	}
	
	private function setupWalls():Void
	{
		Wall.preload();
		
		// Add containing walls.
		var wall:Wall;
		
		wall = new Wall(tilePixelOffsetX - wallSize, tilePixelOffsetY, wallSize, TILE_HEIGHT * levelHeight);
		Wall.group.add(wall);
		
		wall = new Wall(tilePixelOffsetX, tilePixelOffsetY - wallSize, TILE_WIDTH * levelWidth, wallSize);
		Wall.group.add(wall);
		
		wall = new Wall(tilePixelOffsetX + TILE_WIDTH * levelWidth, tilePixelOffsetY, wallSize, TILE_HEIGHT * levelHeight);
		Wall.group.add(wall);
		
		wall = new Wall(tilePixelOffsetX, tilePixelOffsetY + TILE_HEIGHT * levelHeight, TILE_WIDTH * levelWidth, wallSize);
		Wall.group.add(wall);
	}
	
}