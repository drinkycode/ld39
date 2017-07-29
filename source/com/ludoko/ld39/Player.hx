package com.ludoko.ld39;

import flixel.FlxG;
import flixel.FlxSprite;

/**
 * ...
 * @author Michael Lee
 */
class Player extends FlxSprite
{

	public static inline var PLAYER_MAX_SPEED:Float = 160;
	public static inline var PLAYER_ACCELERATION:Float = 1000;
	public static inline var PLAYER_DRAG:Float = 3000;
	
	public var moving:Bool = false;
	
	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/player.png");
		
		maxVelocity.x = maxVelocity.y = PLAYER_MAX_SPEED;
	}
	
	override public function update():Void 
	{
		super.update();
		
		moving = false;
		acceleration.x = acceleration.y = 0;
		
		if (FlxG.keys.anyPressed(["left"]))
		{
			updateMoving();
			acceleration.x = -PLAYER_ACCELERATION;
		}
		else if (FlxG.keys.anyPressed(["right"]))
		{
			updateMoving();
			acceleration.x = PLAYER_ACCELERATION;
		}
		if (FlxG.keys.anyPressed(["up"]))
		{
			updateMoving();
			acceleration.y = -PLAYER_ACCELERATION;
		}
		else if (FlxG.keys.anyPressed(["down"]))
		{
			updateMoving();
			acceleration.y = PLAYER_ACCELERATION;
		}
		
		if (FlxG.keys.anyJustPressed(["x"]))
		{
			addWire();
		}
		
		if (!moving)
		{
			drag.x = drag.y = PLAYER_DRAG;
		}
	}
	
	private function updateMoving():Void 
	{
		moving = true;
		drag.x = drag.y = 0;
	}
	
	public function addWire():Bool
	{
		Wire.create(x, y);
		return true;
	}
	
}