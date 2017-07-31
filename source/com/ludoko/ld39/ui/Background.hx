package com.ludoko.ld39.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Background extends FlxGroup
{

	public var bg:FlxSprite;
	
	public function new() 
	{
		super();
		
		var bgScale:Float = 2;
		bg = new FlxSprite(0, 0, "assets/images/bg.png");
		bg.x = G.halfWidth - bg.frameWidth * 0.5;
		bg.y = G.halfHeight - bg.frameHeight * 0.5;
		bg.scale.x = bg.scale.y = bgScale;
		bg.alpha = 0.3;
		add(bg);
	}
	
}