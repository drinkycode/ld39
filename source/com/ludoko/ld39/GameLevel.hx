package com.ludoko.ld39;

import com.ludoko.ld39.game.Generator;
import com.ludoko.ld39.game.PowerArea;
import com.ludoko.ld39.game.Wall;
import com.ludoko.ld39.ui.Grid;
import flixel.FlxObject;

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

	public static function tilePositionAtX(X:Float)
	{
		return positionAtTileX(tileAtX(X));
	}
	
	public static function tilePositionAtY(Y:Float)
	{
		return positionAtTileY(tileAtY(Y));
	}
	
	public static function positionAtTileX(TileX:Int):Int
	{
		return TileX * GameLevel.TILE_WIDTH + GameLevel.tilePixelOffsetX;
	}
	
	public static function positionAtTileY(TileY:Int):Int
	{
		return TileY * GameLevel.TILE_HEIGHT + GameLevel.tilePixelOffsetY;
	}
	
	public static function tileAtX(X:Float):Int
	{
		return Math.floor((X - GameLevel.tilePixelOffsetX) / TILE_WIDTH);
	}
	
	public static function tileAtY(Y:Float):Int
	{
		return Math.floor((Y - GameLevel.tilePixelOffsetY) / TILE_HEIGHT);
	}
	
	
	
	public static var wallSize:Int = 32;
	
	public var levelWidth:Int;
	public var levelHeight:Int;
	
	public var layers:Array<Layer>;
	public var powerAreas:Array<PowerArea>;
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
			layers.push(layer);
			i--;
		}
		
		powerAreas = new Array<PowerArea>();
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
	
	
	public function removeGameObjectFromLayer(Object:FlxObject, Row:Int):Bool
	{
		if ((Row < 0) || (Row >= levelHeight)) return false;
		return layers[Row].removeGameObject(Object);
	}
	
	public function addGameObjectToLayer(Object:FlxObject, Row:Int):Void
	{
		if ((Row < 0) || (Row >= levelHeight)) return;
		layers[Row].addGameObject(Object);
	}
	
	public function removeCharacterFromLayer(Object:FlxObject, Row:Int):Bool
	{
		if ((Row < 0) || (Row >= levelHeight)) return false;
		return layers[Row].removeCharacter(Object);
	}
	
	public function addCharacterToLayer(Object:FlxObject, Row:Int):Void
	{
		if ((Row < 0) || (Row >= levelHeight)) return;
		layers[Row].addCharacter(Object);
	}
	
	public function removeUIFromLayer(Object:FlxObject, Row:Int):Bool
	{
		if ((Row < 0) || (Row >= levelHeight)) return false;
		return layers[Row].removeUI(Object);
	}
	
	public function addUIToLayer(Object:FlxObject, Row:Int):Void
	{
		if ((Row < 0) || (Row >= levelHeight)) return;
		layers[Row].addUI(Object);
	}
	
	
	public function addGenerator(TileX:Int, TileY:Int, Power:Float, NeededPower:Array<Float>):Generator
	{
		var generator:Generator = Generator.create(TileX, TileY, Power, NeededPower);
		layers[TileY].gameObjects.add(generator);
		return generator;
	}
	
	public function addPowerArea(IncludedTiles:Array<Dynamic>, Power:Float):Void
	{
		var powerArea:PowerArea = new PowerArea(IncludedTiles, Power);
		powerAreas.push(powerArea);
	}
	
	public function darkenArea(DarkenedTiles:Array<Dynamic>):Void
	{
		grid.darkenArea(DarkenedTiles);
	}
	
	public function lightArea(DarkenedTiles:Array<Dynamic>):Void
	{
		grid.lightArea(DarkenedTiles);
	}
	
	public function checkPowerAreas(Generators:Array<Generator>):Void
	{
		for (i in 0 ... powerAreas.length)
		{
			powerAreas[i].checkForPower(Generators);
		}
	}
	
}