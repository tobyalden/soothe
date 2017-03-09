package entities;

import entities.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.masks.*;

class ProcLevel extends Entity
{
  public static inline var TILE_SIZE = 16;
  public static inline var LEVEL_SCALE = 1;

  private var map:Array<Array<Int>>;
  private var tiles:Tilemap;
  private var collisionMask:Grid;
  public var entities:Array<Entity>;

  public var levelWidth:Int;
  public var levelHeight:Int;

  public function new(levelWidth:Int, levelHeight:Int) {
    super(0, 0);
    this.levelWidth = levelWidth;
    this.levelHeight = levelHeight;
    map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
    tiles = new Tilemap("graphics/stone.png", levelWidth*TILE_SIZE, levelHeight*TILE_SIZE, TILE_SIZE, TILE_SIZE);
    entities = new Array<Entity>();
    entities.push(new Player(300, 300, false));
    entities.push(new Player(330, 300, true));
    generateLevel();
    finishInitializing();
  }

  public function finishInitializing()
  {
    tiles.scale = LEVEL_SCALE;
    tiles.loadFrom2DArray(map);
    graphic = tiles;

    collisionMask = new Grid(
      LEVEL_SCALE * levelWidth * TILE_SIZE,
      LEVEL_SCALE * levelHeight * TILE_SIZE,
      LEVEL_SCALE * TILE_SIZE,
      LEVEL_SCALE * TILE_SIZE
    );
    collisionMask.loadFrom2DArray(map);
    mask = collisionMask;
    type = "walls";
    layer = 20;
  }

  public function generateLevel() {
    createBoundaries();
  }

  public function createBoundaries()
  {
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (x == 0 || y == 0 || x == (levelWidth)-1 || y == (levelHeight)-1) {
          map[y][x] = 1;
        }
      }
    }
  }

}
