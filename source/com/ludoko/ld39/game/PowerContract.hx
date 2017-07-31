package com.ludoko.ld39.game;

/**
 * ...
 * @author Michael Lee
 */
class PowerContract
{

	public var sourceGenerator:Generator;
	public var power:Float;
	
	public function new(SourceGenerator:Generator, Power:Float) 
	{
		sourceGenerator = SourceGenerator;
		power = Power;
	}
	
}