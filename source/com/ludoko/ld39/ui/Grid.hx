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

	public var tiles:Array<Array<FlxSprite>>;
	public var tileGroup:FlxGroup;
	
	public var darkenedTiles:Array<Array<FlxSprite>>;
	public var darkenedGroup:FlxGroup;
	
	public function new(Width:Int, Height:Int) 
	{
		super();
		
		tileGroup = new FlxGroup();
		add(tileGroup);
		
		darkenedGroup = new FlxGroup();
		add(darkenedGroup);
		
		tiles = new Array<Array<FlxSprite>>();
		darkenedTiles = new Array<Array<FlxSprite>>();
		
		for (i in 0 ... Width)
		{
			var tileRow:Array<FlxSprite> = new Array<FlxSprite>();
			var darkenedeRow:Array<FlxSprite> = new Array<FlxSprite>();
			
			for (j in 0 ... Height)
			{
				var tile:FlxSprite = createTile(i, j);
				tileGroup.add(tile);
				tileRow.push(tile);
				
				var darkenedTile:FlxSprite = createDarkenedTile(i, j);
				darkenedTile.visible = false;
				darkenedGroup.add(darkenedTile);
				darkenedeRow.push(darkenedTile);
			}
			
			tiles.push(tileRow);
			darkenedTiles.push(darkenedeRow);
		}
	}
	
	private function createTile(X:Int, Y:Int):FlxSprite
	{
		return new FlxSprite(GameLevel.positionAtTileX(X), GameLevel.positionAtTileY(Y), "assets/images/grid.png");
	}
	
	private function createDarkenedTile(X:Int, Y:Int):FlxSprite
	{
		var sprite:FlxSprite = new FlxSprite(GameLevel.positionAtTileX(X), GameLevel.positionAtTileY(Y), "assets/images/grid_dark.png");
		sprite.alpha = 0.3;
		return sprite;
	}
	
	public function darkenArea(DarkenTiles:Array<Dynamic>)
	{
		for (i in 0 ... DarkenTiles.length)
		{
			var tile:Dynamic = DarkenTiles[i];
			darkenedTiles[tile[0]][tile[1]].visible = true;
		}
	}
	
}