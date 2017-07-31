package com.ludoko.ld39.game;

import com.ludoko.ld39.game.Wall;
import com.ludoko.ld39.game.Wire;
import flixel.util.FlxSpriteUtil;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author Michael Lee
 */
class Player extends TileObject
{

	public static inline var PLAYER_MAX_SPEED:Float = 200;
	public static inline var PLAYER_ACCELERATION:Float = 9999;
	public static inline var PLAYER_DRAG:Float = 9999;
	
	public static inline var PLAYER_WIDTH:Int = 32;
	public static inline var PLAYER_HEIGHT:Int = 32;
	
	public static inline var WIRE_CREATE_OFFSET:Int = 20;
	
	public static inline var INITIAL_HEALTH:Int = 3;
	
	
	public var moving:Bool = false;
	public var placing:Bool = false;
	
	private var _hurtTimer:Float = 0;
	
	public function new(X:Float, Y:Float) 
	{
		super();
		
		loadGraphic("assets/images/player.png", true, 48, 96);
		animation.add("side", [10], 0, false);
		animation.add("down", [0], 0, false);
		animation.add("up", [5], 0, false);
		animation.add("sidewalk", [11, 10, 12, 10], 8, true);
		animation.add("downwalk", [1, 0, 2, 0], 8, true);
		animation.add("upwalk", [6, 6, 5, 7, 7, 5], 8, true);
		animation.add("sideplace", [13, 13], 4, false);
		animation.add("downplace", [3, 3], 4, false);
		animation.add("upplace", [8, 8], 4, false);
		animation.add("sidehurt", [14, 14], 2, false);
		animation.add("downhurt", [4, 4], 2, false);
		animation.add("uphurt", [9, 9], 2, false);
		animation.add("die", [15, 16, 17, 18, 19], 10, false);
		
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
		
		health = INITIAL_HEALTH;
		
		// Set player position here
		setCenteredPosition(X, Y);
	}
	
	override public function kill():Void 
	{
		//super.kill();
		alive = false;
		animation.play("die");
	}
	
	public function setCenteredPosition(X:Float, Y:Float):Void
	{
		x = X - PLAYER_WIDTH * 0.5;
		y = Y - PLAYER_HEIGHT * 0.5;
		
		tileY = previousTileY = GameLevel.tileAtY(Y);
		PlayState.instance.currentLevel.addCharacterToLayer(this, tileY);
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
		var previousY:Float = y;
		
		moving = false;
		acceleration.x = acceleration.y = 0;
		
		if (alive)
		{
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
			else
			{
				drag.x = PLAYER_DRAG;
			}
			
			if (FlxG.keys.anyPressed(["up"]))
			{
				updateMoving(false);
				acceleration.y = -PLAYER_ACCELERATION;
			}
			else if (FlxG.keys.anyPressed(["down"]))
			{
				updateMoving(false);
				acceleration.y = PLAYER_ACCELERATION;
			}
			else
			{
				drag.y = PLAYER_DRAG;
			}
			
			if (FlxG.keys.anyJustPressed(["x"]))
			{
				addWire();
			}
		
			if (!moving)
			{
				drag.x = drag.y = PLAYER_DRAG;
				if (!(placing || _hurtTimer>0) || animation.finished && alive)
				{
					switch(facing)
					{
						case FlxObject.UP:
							animation.play("up");
						case FlxObject.DOWN:
							animation.play("down");
						default:
							animation.play("side");
					}
					placing = false;
				}
			}
			else
			{
				if (acceleration.x == 0)
				{
					if (acceleration.y < 0)
					{
						facing = FlxObject.UP;
					}
					else
					{
						facing = FlxObject.DOWN;
					}
				}
				else
				{
					if (acceleration.x < 0)
					{
						facing = FlxObject.LEFT;
					}
					else
					{
						facing = FlxObject.RIGHT;
					}
				}
				
				if (!(_hurtTimer>0) || animation.finished && alive)
				{
					switch(facing)
					{
						case FlxObject.UP:
							animation.play("upwalk");
						case FlxObject.DOWN:
							animation.play("downwalk");
						default:
							animation.play("sidewalk");
					}
					placing = false;
				}
				else if (_hurtTimer > 0)
				{
					switch(facing)
					{
						case FlxObject.UP:
							animation.play("uphurt");
						case FlxObject.DOWN:
							animation.play("downhurt");
						default:
							animation.play("sidehurt");
					}
				}
			}
			
		}
		else
		{
			drag.x = drag.y = PLAYER_DRAG;
		}
		
		super.update();
		
		FlxG.collide(this, Wall.group);
		FlxG.collide(this, Generator.group);
		
		if ((y != previousY))
		{
			var newTileY:Int = GameLevel.tileAtY(y + PLAYER_HEIGHT * 0.5);
			if (previousTileY != newTileY)
			{
				if (PlayState.instance.currentLevel.removeCharacterFromLayer(this, previousTileY))
				{
					PlayState.instance.currentLevel.addCharacterToLayer(this, newTileY);
					previousTileY = newTileY;
				}
			}
		}
		
		_hurtTimer -= FlxG.elapsed;
		
		//if (!alive && animation.name == "die" && animation.finished)
		//{
			//exists = false;
		//}
	}
	
	private function updateMoving(xAxis:Bool = true):Void 
	{
		moving = true;
		if (xAxis)
		{
			drag.x = 0;
		} 
		else
		{
			drag.y = 0;
		}
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
		
		if (!(Util.simpleGroupOverlap(G.o, Wire.group) || Util.simpleGroupOverlap(G.o, Generator.group)))
		{
			switch(facing)
			{
				case FlxObject.UP:
					animation.play("upplace");
				case FlxObject.DOWN:
					animation.play("downplace");
				default:
					animation.play("sideplace");
			}
			placing = true;
			
			Wire.create(centerX + createOffsetX, centerY + createOffsetY);
			return true;
		}
		
		trace("Cannot place wire at " + centerX + createOffsetX + ", " + centerY + createOffsetY);
		return false;
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0 || !alive) return;
		
		super.hurt(Damage);
		_hurtTimer = 1;
		
		if (alive)
		{
			switch(facing)
			{
				case FlxObject.UP:
					animation.play("uphurt");
				case FlxObject.DOWN:
					animation.play("downhurt");
				default:
					animation.play("sidehurt");
			}
			FlxSpriteUtil.flicker(this, 1);
		}
	}
	
	
}