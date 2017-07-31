package com.ludoko.ld39;

import com.ludoko.ld39.G;
import com.ludoko.ld39.game.Generator;
import com.ludoko.ld39.game.Player;
import com.ludoko.ld39.game.Sparkie;
import com.ludoko.ld39.game.Wire;
import com.ludoko.ld39.ui.Background;
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
	public var levelData:TiledLevel;
	
	public var background:Background;
	public var player:Player;
	public var gui:GameGUI;
	
	public var activeGenerators:Array<Generator>;
	
	public var connections:Array<Array<Int>>;
	public var wireConnections:Array<Array<Int>>;
	public var testConnections:Array<Array<Int>>;
	
	public var maxLevels:Int = 16;
	public var level:Int = 0;
	
	public var levelTimer:Float = 0;
	
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
		Sparkie.preload(5);
		
		loadLevel();
		
		background = new Background();
		player = new Player(G.halfWidth, G.halfHeight);
		gui = new GameGUI();
		
		//addGenerator(2, 2, 100, null);
		
		//addGenerator(5, 2, 0, null);
		//currentLevel.addPowerArea([[4, 1], [4, 2], [4, 3], 
		//						   [5, 1], [5, 2], [5, 3],
		//						   [6, 1], [6, 2], [6, 3]],
		//						   50);
		
		//addGenerator(8, 2, 0, null);
		
		//currentLevel.addPowerArea([[8,  7], [8,  8], [8,  9], 
		//						   [9,  7], [9,  8], [9,  9],
		//						   [10, 7], [10, 8], [10, 9]],
		//						   25);
		
		//addSparkie(1, 5);
		
		// Setup adds in proper layering order.
		add(background);
		add(currentLevel);
		add(gui);
	}
	
	public function loadLevel():Void
	{
		var levelWidth:Int = 14;
		var levelHeight:Int = 10;
		
		// Create connections mapping.
		connections = new Array<Array<Int>>();
		wireConnections = new Array<Array<Int>>();
		testConnections = new Array<Array<Int>>();
		
		for (j in 0 ... levelHeight)
		{
			var row:Array<Int> = new Array<Int>();
			var wireRow:Array<Int> = new Array<Int>();
			var testRow:Array<Int> = new Array<Int>();
			
			for (i in 0 ... levelWidth)
			{
				row.push(0);
				wireRow.push(0);
				testRow.push(0);
			}
			
			connections.push(row);
			wireConnections.push(wireRow);
			testConnections.push(testRow);
		}
		
		currentLevel = new GameLevel(14, 10);
		
		levelData = new TiledLevel("assets/data/level.tmx");
		levelData.loadObjects("entities");
	}
	
	public function addGenerator(TileX:Int, TileY:Int, Power:Float = 100, NeededPower:Array<Float>, Source:Bool = false):Generator
	{
		var generator:Generator = currentLevel.addGenerator(TileX, TileY, Power, NeededPower, Source);
		activeGenerators.push(generator);
		return generator;
	}
	
	public function addSparkie(TileX:Int, TileY:Int):Void
	{
		Sparkie.create(GameLevel.positionAtTileX(TileX), GameLevel.positionAtTileY(TileY));
	}
	
	public function checkWireConnections(CheckForEnclosement:Bool = true):Void
	{
		for (j in 0 ... GameLevel.levelHeight)
		{
			for (i in 0 ... GameLevel.levelWidth)
			{
				connections[j][i] = 0;
				wireConnections[j][i] = 0;
				testConnections[j][i] = 0;
			}
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
			wireConnections[wire.tileY][wire.tileX] = 1;
		}
		
		// Check to see if surrounded sparkies are generators.
		if (CheckForEnclosement)
		{
			for (i in 0 ... Sparkie.group.members.length)
			{
				if (!Sparkie.group.members[i].alive) continue;
				
				var sparkie:Sparkie = cast Sparkie.group.members[i];
				
				var sparkieTileX:Int = GameLevel.tileAtX(sparkie.centerX);
				var sparkieTileY:Int = GameLevel.tileAtY(sparkie.centerY);
				
				var isSurrounded:Bool = true;
				if ((sparkieTileX > 0) && (connections[sparkieTileY][sparkieTileX - 1] == 0))
				{
					isSurrounded = false;
				}
				if ((sparkieTileY > 0) && (connections[sparkieTileY - 1][sparkieTileX] == 0))
				{
					isSurrounded = false;
				}
				if ((sparkieTileX < GameLevel.levelWidth - 1) && (connections[sparkieTileY][sparkieTileX + 1] == 0))
				{
					isSurrounded = false;
				}
				if ((sparkieTileY < GameLevel.levelHeight - 1) && (connections[sparkieTileY + 1][sparkieTileX] == 0))
				{
					isSurrounded = false;
				}
				
				if (isSurrounded)
				{
					sparkie.die();
					addGenerator(sparkieTileX, sparkieTileY, 25, null);
					connections[sparkieTileY][sparkieTileX] = 1;
				}
			}
		}
		
		var connectionIndex:Int = 2;
		for (j in 0 ... GameLevel.levelHeight)
		{
			var row:Array<Int> = new Array<Int>();
			for (i in 0 ... GameLevel.levelWidth)
			{
				if (buildConnections(i, j, connections, connectionIndex))
				{
					connectionIndex++;
				}
			}
		}
		
		for (i in 0 ... Wire.group.members.length)
		{
			var wire:Wire = cast Wire.group.members[i];
			if (!wire.alive) continue;
			wire.updateWireConnection(connections);
		}
		
		// Clean up old connections
		for (i in 0 ... activeGenerators.length)
		{
			var j:Int = activeGenerators[i].connections.length - 1;
			while (j >= 0)
			{
				var otherGenerator:Generator = activeGenerators[i].connections[j].sourceGenerator;
				if (connections[activeGenerators[i].tileY][activeGenerators[i].tileX] != connections[otherGenerator.tileY][otherGenerator.tileX])
				{
					removeGeneratorConnection(activeGenerators[i], otherGenerator);
					trace("Removing connection between " + i + " " + j);
				}
				j--;
			}
		}
		
		// Check for new connections.
		for (i in 0 ... activeGenerators.length)
		{
			for (j in i + 1 ... activeGenerators.length)
			{
				if (activeGenerators[i].hasConnection(activeGenerators[j])) continue;
				
				if (connections[activeGenerators[i].tileY][activeGenerators[i].tileX] == connections[activeGenerators[j].tileY][activeGenerators[j].tileX])
				{
					if (checkForDirectConnection(activeGenerators[i], activeGenerators[j]))
					{
						addGeneratorConnection(activeGenerators[i], activeGenerators[j]);
						trace("New connection between " + i + " " + j);
					}
				}
			}
		}
		
		// Start level check to see if player has correct power levels.
		var levelComplete:Bool = true;
		for (i in 0 ... activeGenerators.length)
		{
			if (activeGenerators[i].neededPower != null)
			{
				if (activeGenerators[i].power < activeGenerators[i].neededPower[level])
				{
					levelComplete = false;
					break;
				}
			}
		}
		
		if (levelComplete)
		{
			level++;
			levelTimer = 3;
			//Set level to refresh
		}
		
		checkPowerAreas();
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
		if (X < GameLevel.levelWidth - 1)
		{
			buildConnections(X + 1, Y, Connections, Index);
		}
		if (Y < GameLevel.levelHeight - 1)
		{
			buildConnections(X, Y + 1, Connections, Index);
		}
		
		return true;
	}
	
	private function checkForDirectConnection(Generator1:Generator, Generator2:Generator):Bool 
	{
		// Copy wire connections to test connections.
		for (j in 0 ... GameLevel.levelHeight)
		{
			for (i in 0 ... GameLevel.levelWidth)
			{
				testConnections[j][i] = wireConnections[j][i];
			}
		}
		
		// Mark two generators.
		testConnections[Generator1.tileY][Generator1.tileX] = 1;
		testConnections[Generator2.tileY][Generator2.tileX] = 1;
		
		// Build connections index.
		var connectionIndex:Int = 2;
		for (j in 0 ... GameLevel.levelHeight)
		{
			var row:Array<Int> = new Array<Int>();
			for (i in 0 ... GameLevel.levelWidth)
			{
				if (buildConnections(i, j, testConnections, connectionIndex))
				{
					connectionIndex++;
				}
			}
		}
		
		return (testConnections[Generator1.tileY][Generator1.tileX] == testConnections[Generator2.tileY][Generator2.tileX]);
	}
	
	private function removeGeneratorConnection(Generator1:Generator, Generator2:Generator):Void
	{
		Generator1.removeConnection(Generator2);
		Generator2.removeConnection(Generator1);
	}
	
	private function addGeneratorConnection(Generator1:Generator, Generator2:Generator):Void
	{
		var newPower:Float = (Generator1.power + Generator2.power) * 0.5;
		
		Generator1.addConnection(Generator2, newPower - Generator1.power);
		Generator2.addConnection(Generator1, newPower - Generator2.power);
	}
	
	private function checkPowerAreas():Void
	{
		currentLevel.checkPowerAreas(activeGenerators);
	}
	
	override public function update():Void
	{
		super.update();
		
		var sparkie:Sparkie = cast(Util.firstSimpleGroupOverlap(player, Sparkie.group), Sparkie);
		if (sparkie != null)
		{
			playerOverlapsSparkie(sparkie);
		}
		
		if (FlxG.mouse.justPressed)
		{
			G.setOPosition(FlxG.mouse.x, FlxG.mouse.y);
		
			if (!(Util.simpleGroupOverlap(G.o, Wire.group) || Util.simpleGroupOverlap(G.o, Generator.group)))
			{
				Wire.create(FlxG.mouse.x, FlxG.mouse.y);
			}
			else
			{
				var obj:FlxObject = Util.firstSimpleGroupOverlap(G.o, Wire.group);
				if (obj != null)
				{
					obj.kill();
					checkWireConnections(false);
				}
			}
		}
		
		if (levelTimer > 0)
		{
			levelTimer -= FlxG.elapsed;
			
			if (levelTimer <= 0)
			{
				for (i in 0 ... activeGenerators.length)
				{
					if (activeGenerators[i].neededPower != null)
					{
						activeGenerators[i].checkGeneratorPower();
					}
				}
			}
		}
	}
	
	private function playerOverlapsSparkie(sparkie:Sparkie):Void
	{
		sparkie.animation.play("bump");
		player.hurt(1);
	}
	
}