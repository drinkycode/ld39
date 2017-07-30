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
	
	
	public var power:Float;
	public var startingPower:Float;
	
	public var connections:Array<Generator>;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/generator.png");
		immovable = true;
		
		connections = new Array<Generator>();
	}
	
	public function resetGenerator(TileX:Int, TileY:Int, Power:Float):Void 
	{
		reset(GameLevel.positionAtTileX(TileX), GameLevel.positionAtTileY(TileY));
		power = startingPower = Power;
		
		connections = [];
	}
	
}