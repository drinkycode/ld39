package com.ludoko.ld39.game;

/**
 * ...
 * @author Michael Lee
 */
class TilePointer
{

	public static function create(TileX:Int, TileY:Int):TilePointer
	{
		return new TilePointer(TileX, TileY);
	}
	
	
	public var tileX:Int;
	public var tileY:Int;
	
	public function new(TileX:Int, TileY:Int) 
	{
		tileX = TileX;
		tileY = TileY;
	}
	
}