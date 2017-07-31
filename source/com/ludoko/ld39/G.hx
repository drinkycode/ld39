package com.ludoko.ld39;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxSave;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class G
{
	
	public static var halfWidth:Int;
	public static var halfHeight:Int;
	
	private static var _initialized:Bool = false;
	
	public static function init(UseSystemCursor:Bool = true):Void
	{
		if (_initialized) return;
		
		_initialized = true;
		
		halfWidth = Math.floor(FlxG.width * 0.5);
		halfHeight = Math.floor(FlxG.height * 0.5);
		
		FlxG.mouse.useSystemCursor = UseSystemCursor;
		
		// Make helper FlxObject size to 1x1 pixel.
		o.width = 1;
		o.height = 1;
	}
	
	
	public static var level:Int = 0;
	public static inline var MAX_LEVEL:Int = 15;
	
	public static var scores:Array<Dynamic> = [];
	public static var score:Int = 0;
	
	public static var saves:Array<FlxSave> = [];
	
	// Quick helper variables.
	public static var p:FlxPoint = new FlxPoint();
	public static var o:FlxObject = new FlxObject();
	
	public static function setOPosition(X:Float, Y:Float):Void
	{
		o.x = X;
		o.y = Y;
	}
	
}