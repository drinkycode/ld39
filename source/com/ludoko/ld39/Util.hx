package com.ludoko.ld39;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Michael Lee
 */
class Util
{

	public static function simpleGroupOverlap(Object:FlxObject, Group:FlxGroup):Bool
	{
		if (!Object.alive) return false;
		
		for (i in 0 ... Group.members.length)
		{
			if (!Group.members[i].alive) continue;
			
			var o:FlxObject = cast Group.members[i];
			
			if (!((Object.x > o.x + o.width) || (Object.x + Object.width < o.x) || (Object.y > o.y + o.height) || (Object.y + Object.health < o.y)))
			{
				return true;
			}
		}
		
		return false;
	}
	
}