package com.ludoko.ld39.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

/**
 * The UI panel for the generator.
 * 
 * @author Michael Lee
 */
class GeneratorUI extends FlxSpriteGroup
{
	
	public static var _group:FlxGroup;
	
	public static function preload(Amount:Int):FlxGroup
	{
		if (_group == null)
		{
			_group = new FlxGroup();
		}
		
		for (i in 0 ... Amount)
		{
			createInstance();
		}
		
		return _group;
	}
	
	private static function createInstance():GeneratorUI
	{
		var o:GeneratorUI = new GeneratorUI();
		o.kill();
		_group.add(o);
		return o;
	}

	public static function create(X:Float, Y:Float, Power:Float):GeneratorUI
	{
		var o:GeneratorUI = cast _group.getFirstDead();
		if (o == null)
		{
			o = createInstance();
		}
		o.resetGeneratorUI(X, Y, Power);
		return o;
	}
	
	
	public static inline var UI_WIDTH:Int = 98;
	public static inline var UI_HEIGHT:Int = 50;
	
	public static inline var Y_SPACING:Int = 70;
	
	public var back:FlxSprite;
	public var currentPower:FlxText;
	public var totalPower:FlxText;
	
	public var tileY:Int = -1;

	public function new() 
	{
		super();
		
		back = new FlxSprite(0, 0, "assets/images/ui_generator.png");
		add(back);
		
		// 04B_03B
		currentPower = new FlxText(0, 0, UI_WIDTH, "999");
		currentPower.setFormat(GameGUI.FONT_04B03B, 16, 0xffffff, "center");
		add(currentPower);
		
		totalPower = new FlxText(0, 0, UI_WIDTH, "999");
		totalPower.setFormat(GameGUI.FONT_04B03B, 16, 0xffffff, "center");
		add(totalPower);
		
		alpha = 0.6;
	}
	
	override public function kill():Void 
	{
		super.kill();
		if (PlayState.instance.currentLevel != null)
		{
			PlayState.instance.currentLevel.removeUIFromLayer(this, tileY);
		}
	}
	
	public function resetGeneratorUI(X:Float, Y:Float, Power:Float):Void 
	{
		tileY = GameLevel.tileAtY(Y);
		reset(X - UI_WIDTH * 0.5, Y - UI_HEIGHT * 0.5 - Y_SPACING);
		PlayState.instance.currentLevel.addUIToLayer(this, tileY);
		
		currentPower.x = X - UI_WIDTH + 25;
		currentPower.y = Y - Y_SPACING - 5;
		
		totalPower.x = X - UI_WIDTH * 0.5 + 25;
		totalPower.y = Y - Y_SPACING;
		
		currentPower.text = totalPower.text = Power + "";
	}
	
	public function updatePower(Power:Float, TotalPower:Float = -1):Void
	{
		currentPower.text = Util.shortenFloat(Power) + "";
		if (TotalPower != -1)
		{
			totalPower.text = Util.shortenFloat(TotalPower) + "";
		}
	}
	
}