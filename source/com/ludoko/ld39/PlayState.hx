package com.ludoko.ld39;

import com.ludoko.ld39.G;
import com.ludoko.ld39.game.Generator;
import com.ludoko.ld39.game.Wire;
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
		loadLevel();
		
		// Preloads for pooling.
		Wire.preload(10);
		Generator.preload(3);
		
		activeGenerators = new Array<Generator>();
		
		player = new Player(G.halfWidth, G.halfHeight);
		
		gui = new GameGUI();
		
		
		// Setup adds in proper layering order.
		add(currentLevel);
		
		add(player);
		add(Wire.group);
		
		add(gui);
	}
	
	public function loadLevel():Void
	{
		var levelWidth:Int = 14;
		var levelHeight:Int = 10;
		
		currentLevel = new GameLevel(14, 10);
	}
	
	override public function update():Void
	{
		super.update();
	}
	
}