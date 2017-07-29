package com.ludoko.ld39;

import com.ludoko.ld39.G;
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
	
	public var grid:Grid;
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
		// Currently just a debug grid.
		grid = new Grid(14, 10);
		
		loadLevel();
		
		// Preloads for pooling.
		Wire.preload(10);
		Generator.preload(3);
		
		activeGenerators = new Array<Generator>();
		
		player = new Player(G.halfWidth, G.halfHeight);
		
		gui = new GameGUI();
		
		
		// Setup adds in proper layering order.
		add(grid);
		add(Wire.group);
		
		add(player);
		add(gui);
	}
	
	public function loadLevel():Void
	{
		
	}
	
	override public function update():Void
	{
		super.update();
	}
	
}