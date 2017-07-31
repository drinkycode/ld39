package com.ludoko.ld39.game;

import com.ludoko.ld39.ui.GeneratorUI;
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

	public static function create(TileX:Int, TileY:Int, Power:Float, NeededPower:Array<Float>):Generator
	{
		var o:Generator = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.resetGenerator(TileX, TileY, Power, NeededPower);
		return o;
	}
	
	
	public static inline var HITBOX_WIDTH:Int = 48;
	public static inline var HITBOX_HEIGHT:Int = 48;
	
	public var power:Float;
	public var startingPower:Float;
	//public var totalPower:Float;
	public var neededPower:Array<Float>;
	
	public var checked:Bool = false;
	
	public var connections:Array<Generator>;
	
	public var ui:GeneratorUI;
	
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
	
	public function resetGenerator(TileX:Int, TileY:Int, Power:Float, NeededPower:Array<Float>):Void 
	{
		tileX = TileX;
		tileY = TileY;
		
		reset(GameLevel.positionAtTileX(TileX), GameLevel.positionAtTileY(TileY));
		power = startingPower = Power;
		neededPower = NeededPower;
		//totalPower = neededPower[0];
		
		connections = [];
		
		ui = GeneratorUI.create(x + HITBOX_WIDTH * 0.5, y + HITBOX_HEIGHT * 0.5, Power);
	}
	
	public function hasConnection(ConnectedGenerator:Generator):Bool
	{
		return connections.indexOf(ConnectedGenerator) != -1;
	}
	
	public function redistributePower():Void
	{
		if (checked) return;
		
		checked = true;
		
		var newPower:Float = startingPower;
		
		for (i in 0 ... connections.length)
		{
			newPower += connections[i].startingPower;
		}
		
		newPower /= (connections.length + 1);
		
		setPower(newPower);
		
		for (i in 0 ... connections.length)
		{
			connections[i].checked = true;
			connections[i].setPower(newPower);
		}
	}
	
	public function setPower(NewPower:Float):Void
	{
		power = NewPower;
		
		//if (NewPower <= totalPower)
		//{
			//ui.updatePower(power);
		//}
		//else
		//{
			//totalPower = NewPower;
			//ui.updatePower(power, totalPower);
		//}
		if (neededPower == null)
		{
			ui.updatePower(power);
		}
		else
		{
			ui.updatePower(power, neededPower[PlayState.instance.level]);
		}
	}	
	
}