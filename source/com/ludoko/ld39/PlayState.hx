package com.ludoko.ld39;

import com.ludoko.ld39.G;
import com.ludoko.ld39.game.Generator;
import com.ludoko.ld39.game.Player;
import com.ludoko.ld39.game.Sparkie;
import com.ludoko.ld39.game.Wire;
import com.ludoko.ld39.ui.Background;
import com.ludoko.ld39.ui.GeneratorUI;
import com.ludoko.ld39.ui.Grid;
import flixel.input.keyboard.FlxKey;

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
	
	public static inline var ALLOW_DEBUG:Bool = true;

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
	
	public var spawnSparkies:Bool = false;
	private var _sparkieTimer:Float = 10;
	
	private var _refreshLevel:Float = 0;
	
	override public function create():Void
	{
		instance = this;
		
		super.create();
		
		G.init();
		FlxG.camera.bgColor = 0xffffffff;
		
		gameSetup();
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}
		
		SoundUtil.loadMusic("sewer_circuit", 0.35, true);
		//FlxG.sound.music.play();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
	
	public function gameSetup():Void
	{
		G.level = 0;
		
		activeGenerators = new Array<Generator>();
		
		// Preloads for pooling.
		Wire.preload(10, true);
		Generator.preload(5, true);
		GeneratorUI.preload(5, true);
		Sparkie.preload(5, true);
		
		loadLevel();
		
		background = new Background();
		player = new Player(G.halfWidth, G.halfHeight);
		gui = new GameGUI();
		
		//currentLevel.addPowerArea([[4, 1], [4, 2], [4, 3], 
		//						   [5, 1], [5, 2], [5, 3],
		//						   [6, 1], [6, 2], [6, 3]],
		//						   50);
		
		//currentLevel.addPowerArea([[8,  7], [8,  8], [8,  9], 
		//						   [9,  7], [9,  8], [9,  9],
		//						   [10, 7], [10, 8], [10, 9]],
		//						   25);
		
		
		// Setup adds in proper layering order.
		add(background);
		add(currentLevel);
		add(gui);
		
		currentLevel.gridUI.add(player.tileSelector);
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
		
		// Reorder generator so source generator is always 0-index.
		var sourceGenerator:Generator = null;
		for (i in 0 ... activeGenerators.length)
		{
			if (activeGenerators[i].source)
			{
				sourceGenerator = activeGenerators[i];
				break;
			}
		}
		
		if (sourceGenerator != null)
		{
			activeGenerators.remove(sourceGenerator);
			activeGenerators.insert(0, sourceGenerator);
		}
	}
	
	public function addGenerator(TileX:Int, TileY:Int, Power:Float = 100, NeededPower:Array<Float>, Source:Bool = false):Generator
	{
		var generator:Generator = currentLevel.addGenerator(TileX, TileY, Power, NeededPower, Source);
		if (!Source)
		{
			activeGenerators.push(generator);
		}
		else
		{
			// Start at 1 since 0 should always be a source generator.
			var i:Int = 1;
			while (i < activeGenerators.length)
			{
				if (!activeGenerators[i].source)
				{
					break;
				}
				i++;
			}
			
			if (i < activeGenerators.length)
			{
				activeGenerators.insert(i, generator);
			}
			else
			{
				activeGenerators.push(generator);
			}
		}
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
		
		for (i in 0 ... Wire._group.members.length)
		{
			var wire:Wire = cast Wire._group.members[i];
			if (!wire.alive) continue;
			connections[wire.tileY][wire.tileX] = 1;
			wireConnections[wire.tileY][wire.tileX] = 1;
		}
		
		// Check to see if surrounded sparkies are generators.
		if (CheckForEnclosement)
		{
			for (i in 0 ... Sparkie._group.members.length)
			{
				if (!Sparkie._group.members[i].alive) continue;
				
				var sparkie:Sparkie = cast Sparkie._group.members[i];
				
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
					addGenerator(sparkieTileX, sparkieTileY, 25, null, true);
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
		
		for (i in 0 ... Wire._group.members.length)
		{
			var wire:Wire = cast Wire._group.members[i];
			if (!wire.alive) continue;
			wire.updateWireConnection(connections);
		}
		
		//trace("connections:");
		//for (array in connections) trace(array);

		// Clean up old connections
		var lostConnection:Bool = false;
		for (i in 0 ... activeGenerators.length)
		{
			var j:Int = activeGenerators[i].connections.length - 1;
			while (j >= 0)
			{
				var otherGenerator:Generator = activeGenerators[i].connections[j].sourceGenerator;
				if (connections[activeGenerators[i].tileY][activeGenerators[i].tileX] != connections[otherGenerator.tileY][otherGenerator.tileX] || 
				    !checkForDirectConnection(activeGenerators[i], otherGenerator))
				{
					lostConnection = true;
					removeGeneratorConnection(activeGenerators[i], otherGenerator);
					//trace("Removing connection between " + i + " " + activeGenerators.indexOf(otherGenerator));
				}
				j--;
			}
		}
		
		// Check for new connections.
		var newConnection:Bool = false;
		for (i in 0 ... activeGenerators.length)
		{
			for (j in i + 1 ... activeGenerators.length)
			{
				if (activeGenerators[i].hasConnection(activeGenerators[j])) continue;
				
				if (connections[activeGenerators[i].tileY][activeGenerators[i].tileX] == connections[activeGenerators[j].tileY][activeGenerators[j].tileX])
				{
					if (checkForDirectConnection(activeGenerators[i], activeGenerators[j]))
					{
						newConnection = true;
						addGeneratorConnection(activeGenerators[i], activeGenerators[j]);
						//trace("New connection between " + i + " " + j);
					}
				}
			}
		}
		
		if (newConnection)
		{
			SoundUtil.play("connected");
		}
		
		// Figure out generator power distribution here.
		if (lostConnection || newConnection)
		{
			updatePowerDistribution();
			
			// Print out all contracts for generators.
			/*for (i in 0 ... activeGenerators.length)
			{
				for (j in 0 ... activeGenerators[i].connections.length)
				{
					trace("Generator " + i + " has contract of power " + activeGenerators[i].connections[j].power + " with generator " + activeGenerators.indexOf(activeGenerators[i].connections[j].sourceGenerator));
				}
			}*/
			
			checkPowerAreas();
			checkLevelComplete();
		}
		Wire.setDepths();
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
		//var newPower:Float = (Generator1.power + Generator2.power) * 0.5;
		Generator1.addConnection(Generator2, 0);
		Generator2.addConnection(Generator1, 0);
	}
	
	private function updatePowerDistribution():Void
	{
		// Zero out all power connections.
		for (i in 0 ... activeGenerators.length)
		{
			// Find tree depth from power source.
			activeGenerators[i].sourceDepth = 99;
			activeGenerators[i].depthFromSource();
			
			for (j in 0 ... activeGenerators[i].connections.length)
			{
				activeGenerators[i].connections[j].power = 0;
			}
		}
		
		// Evenly split power amongst initial source generator.
		
		for (i in 0 ... activeGenerators.length)
		{
			if (activeGenerators[i].source)
			{
				recursiveUpdatePowerDistribution(activeGenerators[i], []);
			}
		}
	}
	
	private function recursiveUpdatePowerDistribution(SearchGenerator:Generator, Visited:Array<Generator>):Void
	{
		//trace("Visiting depth " + activeGenerators.indexOf(SearchGenerator) + " " + Visited.length + " " + SearchGenerator.connections.length);
		if ((Visited.length > 6))
		{
			return;
		}
		
		// Find generator connections that are children connections.
		var newConnections:Int = 0;
		for (i in 0 ... SearchGenerator.connections.length)
		{
			var depth:Int = SearchGenerator.connections[i].sourceGenerator.depthFromSource();
			if (!SearchGenerator.connections[i].sourceGenerator.source && (depth > SearchGenerator.depthFromSource()) && (Visited.indexOf(SearchGenerator.connections[i].sourceGenerator) == -1))
			{
				//trace(Visited.length + " " + activeGenerators.indexOf(SearchGenerator) + " Generator connection depth " + depth + " for generator " + activeGenerators.indexOf(SearchGenerator.connections[i].sourceGenerator));
				newConnections++;
			}
		}
		
		if (newConnections > 0)
		{
			var splitPower:Float = SearchGenerator.power / (newConnections + 1);
			//trace(Visited.length + " Has connections " + newConnections + " with power split " + splitPower);
			
			// Split power evenly between children generators.
			for (i in 0 ... SearchGenerator.connections.length)
			{
				if (!SearchGenerator.connections[i].sourceGenerator.source && (SearchGenerator.connections[i].sourceGenerator.depthFromSource() > SearchGenerator.depthFromSource()))
				{
					redoGeneratorContracts(SearchGenerator, SearchGenerator.connections[i].sourceGenerator, splitPower);
				}
			}
			
			// Search in children generators for new connections.
			for (i in 0 ... SearchGenerator.connections.length)
			{
				if (!SearchGenerator.connections[i].sourceGenerator.source && (SearchGenerator.connections[i].sourceGenerator.depthFromSource() > SearchGenerator.depthFromSource()))
				{
					Visited.push(SearchGenerator);
					recursiveUpdatePowerDistribution(SearchGenerator.connections[i].sourceGenerator, Visited);
					Visited.remove(SearchGenerator);
				}
			}
		}
	}
	
	private function redoGeneratorContracts(Generator1:Generator, Generator2:Generator, Power:Float):Void
	{
		Generator1.redoConnection(Generator2, -Power);
		Generator2.redoConnection(Generator1, Power);
	}
	
	private function checkPowerAreas():Void
	{
		currentLevel.checkPowerAreas(activeGenerators);
	}
	
	private function checkLevelComplete():Void
	{
		// Start level check to see if player has correct power levels.
		var levelComplete:Bool = true;
		for (i in 0 ... activeGenerators.length)
		{
			if (activeGenerators[i].neededPower != null)
			{
				if (activeGenerators[i].power < activeGenerators[i].neededPower[G.level])
				{
					levelComplete = false;
					break;
				}
			}
		}
		
		if (levelComplete)
		{
			trace("Level " + G.level + " completed!");
			
			G.level++;
			
			if (G.level > G.MAX_LEVEL)
			{
				G.level = G.MAX_LEVEL;
			}
			else
			{
				// Set level to refresh.
				_refreshLevel = 0.5;
			}
			
			gui.updateLevel(G.level + 1);
		}
	}
	
	private function updateGeneratorUIs():Void
	{
		for (i in 0 ... activeGenerators.length)
		{
			if (activeGenerators[i].neededPower != null)
			{
				activeGenerators[i].checkGeneratorPower();
			}
		}
	}
	
	override public function update():Void
	{
		super.update();
		
		if (FlxG.keys.anyJustPressed(["R"]))
		{
			FlxG.switchState(new PlayState());
		}
		
		var sparkie:FlxObject = Util.firstSimpleGroupOverlap(player, Sparkie._group);
		if (sparkie != null)
		{
			playerOverlapsSparkie(cast(sparkie, Sparkie));
		}
		
		if (ALLOW_DEBUG)
		{
			if (FlxG.keys.anyJustPressed(["LBRACKET"]))
			{
				G.level--;
				if (G.level < 0)
				{
					G.level = 0;
				}
				
				trace("On level " + G.level);
				gui.updateLevel(G.level + 1);
				
				updateGeneratorUIs();
			}
			else if (FlxG.keys.anyJustPressed(["RBRACKET"]))
			{
				G.level++;
				if (G.level > G.MAX_LEVEL)
				{
					G.level = G.MAX_LEVEL;
				}
				
				trace("On level " + G.level);
				gui.updateLevel(G.level + 1);
				
				updateGeneratorUIs();
			}
			
			
			if (FlxG.mouse.justPressed)
			{
				G.setOPosition(FlxG.mouse.x, FlxG.mouse.y);
			
				if (!(Util.simpleGroupOverlap(G.o, Wire._group) || Util.simpleGroupOverlap(G.o, Generator._group)))
				{
					Wire.create(FlxG.mouse.x, FlxG.mouse.y);
					SoundUtil.play("place");
				}
				else
				{
					var obj:FlxObject = Util.firstSimpleGroupOverlap(G.o, Wire._group);
					if (obj != null)
					{
						obj.kill();
						checkWireConnections(false);
						SoundUtil.play("remove");
					}
				}
			}
			
			if (FlxG.keys.anyJustPressed(["G"]))
			{
				var tileX:Int = GameLevel.tileAtX(FlxG.mouse.x);
				var tileY:Int = GameLevel.tileAtY(FlxG.mouse.y);
				addGenerator(tileX, tileY, 25, null, true);
			}
		}
		
		if (spawnSparkies)
		{
			_sparkieTimer -= FlxG.elapsed;
			if (_sparkieTimer <= 0)
			{
				addSparkie(FlxRandom.intRanged(0, GameLevel.levelWidth - 1), FlxRandom.intRanged(0, GameLevel.levelHeight - 1));
				if (G.level < 3)
				{
					_sparkieTimer = FlxRandom.floatRanged(18, 32);
				}
				else
				{
					_sparkieTimer = FlxRandom.floatRanged(12, 22);
				}
			}
		}
		
		if (_refreshLevel > 0)
		{
			_refreshLevel -= FlxG.elapsed;
			
			if (_refreshLevel <= 0)
			{
				gui.levelComplete.show();
				updateGeneratorUIs();
			}
		}
	}
	
	private function playerOverlapsSparkie(sparkie:Sparkie):Void
	{
		sparkie.attack();
		player.hurt(1);
	}
	
}