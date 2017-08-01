package com.ludoko.ld39.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class LevelComplete extends FlxGroup
{
	
	public static inline var MAX_ALPHA:Float = 0.8;
	public static inline var FADE_IN_SPEED:Float = 2;
	public static inline var FADE_OUT_SPEED:Float = 0.666;

	public var complete:FlxSprite;
	
	private var _state:Int = 0;
	private var _timer:Float = 0;
	
	public function new() 
	{
		super();
		
		complete = new FlxSprite(G.halfWidth - 143, G.halfHeight - 85, "assets/images/ui_complete.png");
		add(complete);
		
		visible = false;
	}
	
	public function show():Void
	{
		visible = true;
		complete.alpha = 0;
		
		_state = 1;
		_timer = 3;
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (_state == 1)
		{
			complete.alpha += FlxG.elapsed * FADE_IN_SPEED;
			if (complete.alpha >= MAX_ALPHA)
			{
				complete.alpha = MAX_ALPHA;
				_state = 2;
			}
		}
		else if (_state == 2)
		{
			_timer -= FlxG.elapsed;
			if (_timer <= 0)
			{
				complete.alpha -= FlxG.elapsed * FADE_OUT_SPEED;
				if (complete.alpha <= 0)
				{
					visible = false;
					_state = 0;
				}
			}
		}
	}
	
}