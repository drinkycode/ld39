package com.ludoko.ld39;
import flixel.FlxG;
import flixel.system.FlxSound;

/**
 * ...
 * @author aeveis
 */
class SoundUtil
{

	public static var sounds:Map<String, FlxSound>;
	
	public static function load(Name:String, Volume:Float = 1, Looped:Bool = false):Void
	{
		
		var type:String = ".mp3";
		
		#if neko
			type = ".wav";
		#end
		
		if (sounds == null)
		{
			sounds = new Map<String, FlxSound>();
		}
		
		if (sounds.get(Name) == null)
		{
			var sound:FlxSound = new FlxSound();
			sound.loadEmbedded("assets/sounds/" + Name+type, Looped);
			sounds.set(Name, sound);
		}
	}
	
	public static function loadMusic(Name:String, Volume:Float = 1, Looped:Bool = false):Void
	{
		
		var type:String = ".mp3";
		
		#if neko
			type = ".wav";
		#end
		
		if (sounds == null)
		{
			sounds = new Map<String, FlxSound>();
		}
		
		if (sounds.get(Name) == null)
		{
			var sound:FlxSound = new FlxSound();
			sound.loadEmbedded("assets/music/" + Name+type, Looped);
			sound.volume = Volume;
			FlxG.sound.music = sound;
		}
	}
	
	public static function play(Name:String, ForceRestart:Bool = true, ?Volume:Float, ?Looped:Bool):Void
	{
		
		var type:String = ".mp3";
		
		#if neko
			type = ".wav";
		#end
		
		if (sounds == null)
		{
			sounds = new Map<String, FlxSound>();
		}
		
		if (sounds.get(Name) == null)
		{
			if (Volume == null)
			{
				Volume = 1;
			}
			if (Looped == null)
			{
				Looped = false;
			}
			
			var sound:FlxSound = FlxG.sound.play("assets/sounds/" + Name+type, Volume, Looped, false);
			sounds.set(Name, sound);
		}
		else
		{
			if (Volume != null)
			{
				sounds.get(Name).volume = Volume;
			}
			
			if (!sounds.get(Name).playing)
			{
				sounds.get(Name).play(ForceRestart);
			}
		}
	}
	
	public static function stop(Name:String):Void
	{
		if (sounds.get(Name) != null)
		{
			sounds.get(Name).stop();
		}
	}
	
}