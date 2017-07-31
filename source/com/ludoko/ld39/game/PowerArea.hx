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
	
}