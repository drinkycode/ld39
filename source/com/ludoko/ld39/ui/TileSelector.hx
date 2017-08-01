package com.ludoko.ld39.ui;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * ...
 * @author Michael Lee
 */
class TileSelector extends FlxSprite
{
	
	public static inline var ALPHA:Float = 0.85;
	public static inline var ALPHA_DELTA:Float = 0.05;
	public static inline var ALPHA_SPEED:Float = 8;

	private var _sin:Float = 0;
	
	public function new() 
	{
		super( 9999, -9999);
		loadGraphic("assets/images/ui_tile.png");
		alpha = ALPHA;
	}
	
	public function setTilePosition(TileX:Int, TileY:Int):Void
	{
		x = GameLevel.positionAtTileX(GameLevel.clampTileX(TileX));
		y = GameLevel.positionAtTileY(GameLevel.clampTileY(TileY));
	}
	
	override public function update():Void 
	{
		super.update();
		
		_sin += FlxG.elapsed;
		alpha = ALPHA + Math.sin(_sin) * ALPHA_SPEED * ALPHA_DELTA;
	}
	
}