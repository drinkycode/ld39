package com.ludoko.ld39.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Wire extends TileObject
{
	
	public static var group:FlxGroup;
	
	public static function preload(Amount:Int):FlxGroup
	{
		if (group == null)
		{
			group = new FlxGroup();
		}
		
		for (i in 0 ... Amount)
		{
			createInstance();
		}
		
		return group;
	}
	
	private static function createInstance():Wire
	{
		var o:Wire = new Wire();
		o.kill();
		group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float):Wire
	{
		var o:Wire = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.reset(X, Y);
		return o;
	}
	
	
	public static inline var HITBOX_WIDTH:Int = 48;
	public static inline var HITBOX_HEIGHT:Int = 48;
	
	public function new() 
	{
		super();
		loadGraphic("assets/images/wire.png");
		
		width = HITBOX_WIDTH;
		height = HITBOX_HEIGHT;
		centerOffsets();
	}
	
	override public function kill():Void 
	{
		super.kill();
		if (PlayState.instance.currentLevel != null)
		{
			PlayState.instance.currentLevel.removeGameObjectFromLayer(this, tileY);
		}
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		tileX = GameLevel.tileAtX(X);
		tileY = GameLevel.tileAtY(Y);
		
		super.reset(GameLevel.positionAtTileX(tileX), GameLevel.positionAtTileY(tileY));
		
		PlayState.instance.checkWireConnections();
		PlayState.instance.currentLevel.addGameObjectToLayer(this, tileY);
	}
	
}