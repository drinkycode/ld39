package com.ludoko.ld39.game;
import flixel.FlxSprite;

/**
 * ...
 * @author Michael Lee
 */
class TileObject extends FlxSprite
{

	public var tileX:Int;
	public var tileY:Int;
	
	public var previousTileX:Int;
	public var previousTileY:Int;
	
	public function new() 
	{
		super( -9999, -9999);
		tileX = tileY = -1;
		previousTileX = previousTileY = -1;
	}
	
}