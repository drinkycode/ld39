package com.ludoko.ld39.game;

import com.ludoko.ld39.ui.GeneratorUI;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxColorUtil;

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

	public static function create(TileX:Int, TileY:Int, Power:Float, NeededPower:Array<Float>, Source:Bool = false):Generator
	{
		var o:Generator = cast group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.resetGenerator(TileX, TileY, Power, NeededPower, Source);
		return o;
	}
	
	
	public static inline var HITBOX_WIDTH:Int = 48;
	public static inline var HITBOX_HEIGHT:Int = 48;
	
	public var power(get, null):Float;
	public function get_power():Float
	{
		if (!hasSource()) return 0;
		
		var power:Float = startingPower;
		for (i in 0 ... connections.length)
		{
			power += connections[i].power;
		}
		return power;
	}
	
	public var startingPower:Float;
	public var source:Bool = false;
	public var sourceDepth:Int = -1;
	
	public var visited:Bool;
	
	public var neededPower:Array<Float>;
	
	public var checkPower:Bool = false;
	
	public var connections:Array<PowerContract>;
	
	public var ui:GeneratorUI;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/generator.png");
		immovable = true;
		
		width = HITBOX_WIDTH;
		height = HITBOX_HEIGHT;
		offset.y = 64 - HITBOX_HEIGHT;
		
		connections = new Array<PowerContract>();
	}
	
	public function resetGenerator(TileX:Int, TileY:Int, Power:Float, NeededPower:Array<Float>, Source:Bool = false):Void 
	{
		tileX = TileX;
		tileY = TileY;
		
		reset(GameLevel.positionAtTileX(TileX), GameLevel.positionAtTileY(TileY));
		startingPower = Power;
		source = Source;
		if (startingPower == 100)
		{
			loadGraphic("assets/images/start_generator.png");
		}
		
		neededPower = NeededPower;
		//totalPower = neededPower[0];
		
		connections = [];
		
		ui = GeneratorUI.create(x + HITBOX_WIDTH * 0.5, y + HITBOX_HEIGHT * 0.5, Power);
		updatePower();
	}
	
	public function hasSource(Deep:Int = 0):Bool
	{
		if (Deep >= 3)
		{
			return source;
		}
		
		if (source)
		{
			return true;
		}
		
		for (i in 0 ... connections.length)
		{
			if (connections[i].sourceGenerator.hasSource(Deep + 1))
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function depthFromSource():Int
	{
		if (sourceDepth != -1)
		{
			return sourceDepth;
		}
		
		sourceDepth = recursiveDepthFromSource();
		return sourceDepth;
	}
	
	private function recursiveDepthFromSource(Depth:Int = 0):Int
	{
		if (Depth >= 5)
		{
			return Depth;
		}
		
		if (source)
		{
			return Depth;
		}
		
		var newDepth:Int = 99;
		for (i in 0 ... connections.length)
		{
			var d:Int = connections[i].sourceGenerator.recursiveDepthFromSource(Depth + 1);
			if (d < newDepth)
			{
				newDepth = d;
			}
		}
		
		return newDepth;
	}
	
	public function hasConnection(ConnectedGenerator:Generator):Bool
	{
		return (findContract(ConnectedGenerator) != null);
	}
	
	public function findContract(ConnectedGenerator:Generator):PowerContract
	{
		var connected:Bool = false;
		for (i in 0 ... connections.length)
		{
			if (connections[i].sourceGenerator == ConnectedGenerator)
			{
				return connections[i];
			}
		}
		return null;
	}
	
	public function addConnection(OtherGenerator:Generator, AddedPower:Float):Void
	{
		trace("Adding power " + AddedPower);
		connections.push(new PowerContract(OtherGenerator, AddedPower));
		checkGeneratorPower();
	}
	
	public function removeConnection(OtherGenerator:Generator):Void
	{
		var i:Int = connections.length - 1;
		while (i >= 0)
		{
			if (connections[i].sourceGenerator == OtherGenerator)
			{
				connections.remove(connections[i]);
				break;
			}
			i--;
		}
		
		checkGeneratorPower();
	}
	
	public function redoConnection(OtherGenerator:Generator, PowerMagnitude:Float):Void
	{
		var contract:PowerContract = findContract(OtherGenerator);
		contract.power = PowerMagnitude;
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (checkPower)
		{
			updatePower();
		}
	}
	
	public function checkGeneratorPower():Void
	{
		checkPower = true;
		for (i in 0 ... connections.length)
		{
			connections[i].sourceGenerator.checkPower = true;
		}
	}
	
	public function updatePower():Void
	{
		/*if (NewPower <= totalPower)
		{
			ui.updatePower(power);
		}
		else
		{
			totalPower = NewPower;
			ui.updatePower(power, totalPower);
		}*/
		
		
		if (neededPower == null)
		{
			ui.updatePower(power);
		}
		else
		{
			ui.updatePower(power, neededPower[G.level]);
			color = FlxColorUtil.interpolateColor(0x1faec3, FlxColor.WHITE, 100, Math.floor(Math.min(100 * power / neededPower[G.level], 100)));
		}
	}	
	
}