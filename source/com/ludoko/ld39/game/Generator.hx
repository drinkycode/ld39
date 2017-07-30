package com.ludoko.ld39.game;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Generator extends TileObject
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
	
	private static function createInstance():Generator
	{
		var o:Generator = new Generator();
		o.kill();
		group.add(o);
		return o;
	}

	public static function create(TileX:Int, TileY:Int, Power:Float):Generator
	{
		var o:Generator = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.resetGenerator(TileX, TileY, Power);
		return o;
	}
	
	
	public static inline var HITBOX_WIDTH:Int = 48;
	public static inline var HITBOX_HEIGHT:Int = 48;
	
	public var power:Float;
	public var startingPower:Float;
	
	public var connections:Array<Generator>;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/generator.png");
		immovable = true;
		
		width = HITBOX_WIDTH;
		height = HITBOX_HEIGHT;
		offset.y = 64 - HITBOX_HEIGHT;
		
		connections = new Array<Generator>();
	}
	
	public function resetGenerator(TileX:Int, TileY:Int, Power:Float):Void 
	{
		tileX = TileX;
		tileY = TileY;
		
		reset(GameLevel.positionAtTileX(TileX), GameLevel.positionAtTileY(TileY));
		power = startingPower = Power;
		
		connections = [];
	}
	
	public function hasConnection(ConnectedGenerator:Generator):Bool
	{
		return connections.indexOf(ConnectedGenerator) != -1;
	}
	
}