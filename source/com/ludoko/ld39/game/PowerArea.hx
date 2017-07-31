package com.ludoko.ld39.game;

import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class PowerArea extends FlxGroup
{
	
	public var neededPower:Float = 0;
	public var tiles:Array<Dynamic>;
	
	public function new(IncludedTiles:Array<Dynamic>, NeededPower:Float) 
	{
		super();
		neededPower = NeededPower;
		tiles = IncludedTiles;
		
		PlayState.instance.currentLevel.darkenArea(tiles);
	}
	
	public function checkForPower(Generators:Array<Generator>):Void
	{
		var power:Float = 0;
		
		for (i in 0 ... tiles.length)
		{
			var tile:Dynamic = tiles[i];
			power += powerAtTile(Generators, tile[0], tile[1]);
		}
		
		if (power >= neededPower)
		{
			PlayState.instance.currentLevel.lightArea(tiles);
		}
		else
		{
			PlayState.instance.currentLevel.darkenArea(tiles);
		}
	}
	
	private function powerAtTile(Generators:Array<Generator>, TileX:Int, TileY:Int):Float
	{
		var power:Float = 0;
		for (i in 0 ... Generators.length)
		{
			if ((Generators[i].tileX == TileX) && (Generators[i].tileY == TileY))
			{
				return Generators[i].power;
			}
		}
		return power;
	}
	
}