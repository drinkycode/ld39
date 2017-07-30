package com.ludoko.ld39.game;

import com.ludoko.ld39.game.Wall;
import com.ludoko.ld39.game.Wire;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author Michael Lee
 */
class Player extends FlxSprite
{

	public static inline var PLAYER_MAX_SPEED:Float = 200;
	public static inline var PLAYER_ACCELERATION:Float = 9999;
	public static inline var PLAYER_DRAG:Float = 9999;
	
	public static inline var PLAYER_WIDTH:Int = 32;
	public static inline var PLAYER_HEIGHT:Int = 32;
	
	public static inline var WIRE_CREATE_OFFSET:Int = 16;
	
	
	public var moving:Bool = false;
	
	public function new(X:Float, Y:Float) 
	{
		super(-9999, -9999);
		
		loadGraphic("assets/images/player.png", true, 48, 96);
		animation.add("side", [0], 0, false);
		animation.add("down", [1], 0, false);
		animation.add("up", [2], 0, false);
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.DOWN, false, false);
		setFacingFlip(FlxObject.UP, false, false);
		
		// Set up hitbox
		width = PLAYER_WIDTH;
		height = PLAYER_HEIGHT;
		offset.x = Math.floor((frameWidth - width) * 0.5);
		offset.y = frameHeight - height - 8;
		
		maxVelocity.x = maxVelocity.y = PLAYER_MAX_SPEED;
		
		// Set player position here
		setCenteredPosition(X, Y);
	}
	
	public function setCenteredPosition(X:Float, Y:Float):Void
	{
		x = X - PLAYER_WIDTH * 0.5;
		y = Y - PLAYER_HEIGHT * 0.5;
	}
	
	public var centerX(get, null):Float;
	public function get_centerX():Float
	{
		return x + PLAYER_WIDTH * 0.5;
	}
	
	public var centerY(get, null):Float;
	public function get_centerY():Float
	{
		return y + PLAYER_HEIGHT * 0.5;
	}
	
	override public function update():Void 
	{
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
		else
		{
			if (acceleration.x == 0)
			{
				if (acceleration.y < 0)
				{
					animation.play("up");
					facing = FlxObject.UP;
				}
				else
				{
					animation.play("down");
					facing = FlxObject.DOWN;
				}
			}
			else
			{
				animation.play("side");
				if (acceleration.x < 0)
				{
					facing = FlxObject.LEFT;
				}
				else
				{
					facing = FlxObject.RIGHT;
				}
			}
		}
		
		super.update();
		
		FlxG.collide(this, Wall.group);
	}
	
	private function updateMoving():Void 
	{
		moving = true;
		drag.x = drag.y = 0;
	}
	
	public function addWire():Bool
	{
		var createOffsetX:Float = 0;
		var createOffsetY:Float = 0;
		
		switch (facing) 
		{
			case FlxObject.LEFT:
				createOffsetX = -WIRE_CREATE_OFFSET;
			case FlxObject.RIGHT:
				createOffsetX = WIRE_CREATE_OFFSET;
			case FlxObject.UP:
				createOffsetY = -WIRE_CREATE_OFFSET;
			case FlxObject.DOWN:
				createOffsetY = WIRE_CREATE_OFFSET;
		}
		
		G.setOPosition(centerX + createOffsetX, centerY + createOffsetY);
		
		if (!FlxG.overlap(Wire.group, G.o))
		{
			Wire.create(centerX + createOffsetX, centerY + createOffsetY);
			return true;
		}
		
		trace("Cannot place wire at " + centerX + createOffsetX + ", " + centerY + createOffsetY);
		return false;
	}
	
}