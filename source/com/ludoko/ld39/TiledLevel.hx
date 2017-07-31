package com.ludoko.ld39;
import com.ludoko.ld39.game.Generator;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author aeveis
 */
class TiledLevel extends TiledMap
{
	
	public var px:Float;
	public var py:Float;
	
	public function new(TMXPath:Dynamic) 
	{
		super(TMXPath);
		//FlxG.log.add(fullWidth + " " + fullHeight);
		//FlxG.worldBounds.set(0, 0, fullWidth, fullHeight);
		//FlxG.camera.setBounds(0, 0, fullWidth, fullHeight);
		//FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight);
	}
	
	/**
	 * 
	 * @param	TiledLayerName Assumed layer name is same as image name
	 * @return
	 */
	public function loadTileMap(TiledLayerName:String): FlxTilemap
	{
		var tiledLayer:TiledLayer = getLayer(TiledLayerName);
		//if (tiledLayer.type != TiledLayerType.TILE) throw "Tiled Layer " + TiledLayerName + "is not a tile layer"; 
		var tileSet:TiledTileSet = getTileSet(TiledLayerName);
		var tilemap:FlxTilemap = new FlxTilemap();
			
		//fix so tile id is correct for FlxTileMap
		var mapData:Array<Int> = new Array<Int>();
		for (i in tiledLayer.tileArray) {
			if (i != 0) mapData.push(i - (tileSet.firstGID));
			else mapData.push(0);
		}
	
		tilemap.loadMap(mapData, "assets/data/" + TiledLayerName+".png", tileSet.tileWidth, tileSet.tileHeight, 0, 0, 0, 1);
		//tilemap.loadMapFromArray(mapData, width, height, Assets.getFile(tiledLayer.name), tileSet.tileWidth, tileSet.tileHeight, 0, 0, 1);
		return tilemap;
		
	}
	/**
	 * load anything else not a tile map
	 * @param	TiledLayerName
	 * @param	state
	 */
	public function loadObjects(TiledLayerName:String) 
	{
		var tiledLayer:TiledObjectGroup = getObjectGroup(TiledLayerName);
		//if (tiledLayer.type != TiledLayerType.OBJECT) throw "Tiled Layer " + TiledLayerName + "is not a object layer"; 
		for (obj in tiledLayer.objects) {
			var x:Float = obj.x;
			var y:Float = obj.y-obj.height;
			
			// objects in tiled are aligned bottom-left (top-left in flixel)
			//if (obj.gid != -1)
			//	y -= tiledLayer.map.getGidOwner(obj.gid).tileHeight;
				
			switch(obj.name.toLowerCase()) {
				//Example, includes getting custom props in tiled
				//case "plant":
					//var plant:Plant = new Plant(x, y, PlantState.Grown, Std.parseInt(obj.properties.get("children")));
					//if (obj.properties.get("suspended") == "true")
					//{
						//plant.suspended = true;
					//}
					//state.plants.add(plant);
					//state.plantsOverlap.add(plant.overlapHitBox);
				case "start_generator":
					var levels = new Array<Float>();
					for (i in 0...PlayState.instance.maxLevels)
					{
						levels.push(Std.parseFloat(obj.custom.get("level" + i)));
					}
					PlayState.instance.addGenerator(getTileX(x), getTileY(y), 100, levels, true);
				case "generator":
					var levels = new Array<Float>();
					for (i in 0...PlayState.instance.maxLevels)
					{
						levels.push(Std.parseFloat(obj.custom.get("level" + i)));
					}
					PlayState.instance.addGenerator(getTileX(x), getTileY(y), 0, levels);
				case "sparkie":
					PlayState.instance.addSparkie(getTileX(x), getTileY(y));
					
			}
		}
	}
	
	private function getTileX(X:Float):Int
	{
		return Math.floor(X / GameLevel.TILE_WIDTH);
	}
	
	private function getTileY(Y:Float):Int
	{
		return Math.floor(Y / GameLevel.TILE_HEIGHT);
	}
}