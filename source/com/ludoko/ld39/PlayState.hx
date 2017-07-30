package com.ludoko.ld39;

import com.ludoko.ld39.G;
import com.ludoko.ld39.game.Generator;
import com.ludoko.ld39.game.Player;
import com.ludoko.ld39.game.Wire;
import com.ludoko.ld39.ui.GeneratorUI;
import com.ludoko.ld39.ui.Grid;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{

	public static var instance:PlayState;
	
	public var currentLevel:GameLevel;
	
	public var player:Player;
	public var gui:GameGUI;
	
	public var activeGenerators:Array<Generator>;
	
	override public function create():Void
	{
		instance = this;
		
		super.create();
		
		G.init();
		FlxG.camera.bgColor = 0xffffffff;
		
		gameSetup();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
	
	public function gameSetup():Void
	{
		activeGenerators = new Array<Generator>();
		
		// Preloads for pooling.
		Wire.preload(10);
		Generator.preload(5);
		GeneratorUI.preload(5);
		
		loadLevel();
		
		player = new Player(G.halfWidth, G.halfHeight);
		gui = new GameGUI();
		
		addGenerator(2, 2, 100);
		addGenerator(5, 2, 0);
		addGenerator(8, 2, 0);
		
		// Setup adds in proper layering order.
		add(currentLevel);
		add(gui);
	}
	
	public function loadLevel():Void
	{
		var levelWidth:Int = 14;
		var levelHeight:Int = 10;
		
		currentLevel = new GameLevel(14, 10);
	}
	
	public function addGenerator(TileX:Int, TileY:Int, Power:Float = 100):Void
	{
		var generator:Generator = currentLevel.addGenerator(TileX, TileY, Power);
		activeGenerators.push(generator);
	}
	
	public function checkWireConnections():Void
	{
		var connections:Array<Array<Int>> = new Array<Array<Int>>();
		
		for (j in 0 ... currentLevel.levelHeight)
		{
			var row:Array<Int> = new Array<Int>();
			for (i in 0 ... currentLevel.levelWidth)
			{
				row.push(0);
			}
			connections.push(row);
		}
		
		for (i in 0 ... activeGenerators.length)
		{
			connections[activeGenerators[i].tileY][activeGenerators[i].tileX] = 1;
		}
		
		for (i in 0 ... Wire.group.members.length)
		{
			var wire:Wire = cast Wire.group.members[i];
			if (!wire.alive) continue;
			connections[wire.tileY][wire.tileX] = 1;
		}
		
		var index:Int = 2;
		
		for (j in 0 ... currentLevel.levelHeight)
		{
			var row:Array<Int> = new Array<Int>();
			for (i in 0 ... currentLevel.levelWidth)
			{
				if (buildConnections(i, j, connections, index))
				{
					index++;
				}
			}
		}
		
		for (i in 0 ... activeGenerators.length)
		{
			for (j in i + 1 ... activeGenerators.length)
			{
				if (activeGenerators[i].hasConnection(activeGenerators[j])) continue;
				
				if (connections[activeGenerators[i].tileY][activeGenerators[i].tileX] == connections[activeGenerators[j].tileY][activeGenerators[j].tileX])
				{
					addGeneratorConnection(activeGenerators[i], activeGenerators[j]);
					trace("New connection between " + i + " " + j);
				}
			}
		}
	}
	
	private function buildConnections(X:Int, Y:Int, Connections:Array<Array<Int>>, Index:Int):Bool
	{
		if (Connections[Y][X] != 1) return false;
		
		Connections[Y][X] = Index;
		
		if (X > 0)
		{
			buildConnections(X - 1, Y, Connections, Index);
		}
		if (Y > 0)
		{
			buildConnections(X, Y - 1, Connections, Index);
		}
		if (X < currentLevel.levelWidth - 1)
		{
			buildConnections(X + 1, Y, Connections, Index);
		}
		if (Y < currentLevel.levelHeight - 1)
		{
			buildConnections(X, Y + 1, Connections, Index);
		}
		
		return true;
	}
	
	private function addGeneratorConnection(Generator1:Generator, Generator2:Generator):Void
	{
		Generator1.connections.push(Generator2);
		Generator2.connections.push(Generator1);
		
		var newPower:Float = (Generator1.power + Generator2.power) * 0.5;
		Generator1.setPower(newPower);
		Generator2.setPower(newPower);
	}
	
	override public function update():Void
	{
		super.update();
		
		if (FlxG.mouse.justPressed)
		{
			G.setOPosition(FlxG.mouse.x, FlxG.mouse.y);
		
			if (!(Util.simpleGroupOverlap(G.o, Wire.group) || Util.simpleGroupOverlap(G.o, Generator.group)))
			{
				Wire.create(FlxG.mouse.x, FlxG.mouse.y);
			}
			else
			{
				trace("Cannot create wire at " + FlxG.mouse.x + ", " + FlxG.mouse.y);
			}
		}
	}
	
}