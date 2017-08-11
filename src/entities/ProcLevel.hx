package entities;

import entities.*;
import flash.geom.Point;
import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
import com.haxepunk.masks.*;

class ProcLevel extends Entity
{
  public static inline var TILE_SIZE = 7;
  /*public static inline var levelScale = 3;*/
  public static inline var BIGGIFY_SCALE = 5;

  public static inline var OFFSET_CHANCE = 0.01;
  public static inline var FILL_CHANCE = 0.75;
  public static inline var DETAIL_REPEAT = 5;
  public static inline var OFFSET_SIZE = 5;

  private var map:Array<Array<Int>>;
  private var tiles:Tilemap;
  private var collisionMask:Grid;
  public var entities:Array<Entity>;
  public var player:Player;

  public var levelWidth:Int;
  public var levelHeight:Int;
  public var levelScale:Int;
  public var hasSubLevel:Bool;

  public function new(x:Int, y:Int, levelWidth:Int, levelHeight:Int, levelScale:Int, hasSubLevel:Bool) {
    super(x, y);
    this.levelWidth = levelWidth;
    this.levelHeight = levelHeight;
    this.levelScale = levelScale;
    this.hasSubLevel = hasSubLevel;
    map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
    entities = new Array<Entity>();
    generateLevel();
    if(hasSubLevel) {
      createSubLevel();
    }
    addEntitiesToScene();
    finishInitializing();
  }

  public function finishInitializing() {
    tiles.scale = levelScale;
    tiles.smooth = false;
    graphic = tiles;
    tiles.loadFrom2DArray(map);
    collisionMask = new Grid(
      levelScale * levelWidth * TILE_SIZE,
      levelScale * levelHeight * TILE_SIZE,
      levelScale * TILE_SIZE,
      levelScale * TILE_SIZE
    );
    collisionMask.loadFrom2DArray(map);
    mask = collisionMask;
    type = "walls";
    layer = 20;
  }

  public function generateLevel() {
    randomizeMap();
    connectAndContainAllRooms();
    createBoundaries();
    biggifyMap();
    for (i in -Math.round(DETAIL_REPEAT/2)...Math.round(DETAIL_REPEAT/2)) {
      detailMap(OFFSET_SIZE + i - 1);
    }
    widenPassages();
    removeFloaters();
    createBoundaries();
    tiles = new Tilemap(
      "graphics/stone.png",
      TILE_SIZE * this.levelWidth,
      TILE_SIZE * this.levelHeight,
      TILE_SIZE,
      TILE_SIZE
    );
    placeWater();
    /*if(hasSubLevel) {*/
      placePlayers();
      placeEnemies();
      placeDoors();
    /*}*/
    prettifyMap();
  }

  public function randomizeMap() {
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        map[y][x] = Math.round(Math.random() * 0.7);
      }
    }
  }

  public function connectAndContainAllRooms() {
    createBoundaries();
    var rooms:Array<Array<Int>> = getRooms();
    connectRooms(rooms);
  }

  public function createBoundaries() {
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

  public function biggifyMap() {
    var bigMap = [
      for (y in 0...levelHeight * BIGGIFY_SCALE) [
        for (x in 0...levelWidth * BIGGIFY_SCALE) 0
      ]
    ];
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
          for(scaleX in 0...BIGGIFY_SCALE)
          {
              for(scaleY in 0...BIGGIFY_SCALE)
              {
                  bigMap[y * OFFSET_SIZE + scaleY][x * OFFSET_SIZE + scaleX] = (
                    map[y][x]
                  );
              }
          }
      }
    }
    levelWidth = levelWidth * BIGGIFY_SCALE;
    levelHeight = levelHeight * BIGGIFY_SCALE;
    map = bigMap;
  }

  public function detailMap(offsetSize:Int) {
    if(offsetSize < 2) {
      offsetSize = 2;
    }
    for (x in 0...levelWidth - BIGGIFY_SCALE - Math.round(TILE_SIZE/2))
    {
      for (y in 0...levelHeight - BIGGIFY_SCALE - Math.round(TILE_SIZE/2))
      {
        if(Math.random() < OFFSET_CHANCE)
        {
          var fill = Math.round(Math.random() * FILL_CHANCE);
          for(scaleX in 0...offsetSize)
          {
            for(scaleY in 0...offsetSize)
            {
                var offsetX = x + scaleX + Math.round(TILE_SIZE/2);
                var offsetY = y + scaleY + Math.round(TILE_SIZE/2);
                if(
                  offsetX >= 0 && offsetX < levelWidth
                  && offsetY >= 0
                  && offsetY < levelHeight
                ) {
                  map[offsetY][offsetX] = fill;
                }
            }
          }
        }
      }
    }
  }

  public function widenPassages() {
    for (x in 1...levelWidth - 1) {
      for(y in 1...levelHeight - 1) {
        if(map[y][x] == 0) {
          if(map[y - 1][x] == 1 && map[y + 1][x] == 1) {
            map[y - 1][x] = 0;
            map[y + 1][x] = 0;
          }
          else if(map[y][x - 1] == 1 && map[y][x + 1] == 1) {
            map[y][x - 1] = 0;
            map[y][x + 1] = 0;
          }
        }
      }
    }
  }

  public function removeFloaters() {
    for (x in 1...levelWidth - 1) {
      for(y in 1...levelHeight - 1) {
        if(map[y][x] == 1) {
          if(emptyNeighbors(x, y, 1) == 8) {
            map[y][x] = 0;
          }
        }
      }
    }
  }

  public function placeWater() {
    for (x in 21...levelWidth - 1)
    {
      for (y in 0...levelHeight - 1)
      {
        if(map[y][x] == 0 && map[y][x - 1] == 1 && map[y + 1][x] == 1) {
          var scanX = 1;
          var addWater = true;
          while(map[y][x + scanX] == 0 && scanX < levelWidth - 1) {
            if(map[y + 1][x + scanX] == 0) {
              addWater = false;
              break;
            }
            scanX += 1;
          }
          if(addWater) {
            var water = new Water(
              x * TILE_SIZE * levelScale,
              y * TILE_SIZE * levelScale + 8,
              TILE_SIZE * levelScale * scanX,
              TILE_SIZE * levelScale - 8
            );
            entities.push(water);
          }
        }
      }
    }
  }

  public function placePlayers() {
      var point = pickRandomPointOnGround();
      var player = new Player(
        Math.round(point.x) * TILE_SIZE * levelScale,
        Math.round(point.y) * TILE_SIZE * levelScale - 24
      );
      this.player = player;
      entities.push(player);
      entities.push(new Option(player));
      entities.push(new Sword(player));
  }

  public function placeEnemies() {
      for(i in 0...25) {
        var point = pickRandomOpenPoint();
        var luster = new Luster(
          Math.round(point.x) * TILE_SIZE * levelScale,
          Math.round(point.y) * TILE_SIZE * levelScale
          );
          entities.push(luster);
      }
  }

  public function placeDoors() {
    for(i in 0...25) {
        var point = pickRandomPointOnGround();
        var door = new Door(
          Math.round(point.x) * TILE_SIZE * levelScale,
          Math.round(point.y) * TILE_SIZE * levelScale
        );
        entities.push(door);
    }
  }

  public function prettifyMap() {
    var count:Int = 1;
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if(map[y][x] != 0)
        {
          map[y][x] = count;
          count++;
          if(count > tiles.tileCount)
          {
            count = 1;
          }
        }
      }
    }
    tiles.loadFrom2DArray(map);
  }

  public function addEntitiesToScene() {
    for (entity in entities) {
      HXP.scene.add(entity);
    }
  }

  // HELPER FUNCTIONS

  public function getRooms()
  {
    var roomCount:Int = 0;
    var rooms:Array<Array<Int>> = [
      for (y in 0...levelHeight) [
        for (x in 0...levelWidth) 0
      ]
    ];
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (map[y][x] == 0 && rooms[y][x] == 0) {
          roomCount += 1;
          floodFill(x, y, rooms, roomCount);
        }
      }
    }
    return rooms;
  }

  public function emptyMap()
  {
    map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
  }

  public function invertMap()
  {
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (map[y][x] == 1) {
          map[y][x] = 0;
        } else {
          map[y][x] = 1;
        }
      }
    }
  }

  public function cellularAutomata()
  {
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (emptyNeighbors(x, y, 1) >= 6 + Math.round(Math.random())) {
          map[y][x] = 1;
        } else {
          map[y][x] = 0;
        }
      }
    }
  }

  public function emptyNeighbors(tileX:Int, tileY:Int, radius:Int)
  {
    var emptyNeighbors:Int = 0;
    var x:Int = tileX - radius;
    while (x <= tileX + radius)
    {
      var y:Int = tileY - radius;
      while (y <= tileY + radius)
      {
        if (isWithinMap(x, y) && map[y][x] == 0) {
          emptyNeighbors += 1;
        }
        y += 1;
      }
      x += 1;
    }
    return emptyNeighbors;
  }

  public function isWithinMap(x:Int, y:Int)
  {
    return x >= 0 && y >= 0 && x < levelWidth && y < levelHeight;
  }

  public function countRooms()
  {
    var roomCount:Int = 0;
    var rooms:Array<Array<Int>> = [
      for (y in 0...levelHeight) [
        for (x in 0...levelWidth) 0
      ]
    ];
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (map[y][x] == 0 && rooms[y][x] == 0) {
          roomCount += 1;
          floodFill(x, y, rooms, roomCount);
        }
      }
    }
    return roomCount;
  }


  public function floodFill(x:Int, y:Int, rooms:Array<Array<Int>>, fill:Int)
  {
    if (isWithinMap(x, y) && map[y][x] == 0 && rooms[y][x] == 0) {
      rooms[y][x] = fill;
      floodFill(x + 1, y, rooms, fill);
      floodFill(x - 1, y, rooms, fill);
      floodFill(x, y + 1, rooms, fill);
      floodFill(x, y - 1, rooms, fill);
    }
  }

  public function connectRooms(rooms:Array<Array<Int>>)
  {
    // TODO: pick all the points in one go
    var p1:Point = null;
    var p2:Point = null;

    for (x in 0...levelWidth)
    {
      if(p1 != null)
      {
        break;
      }
      for (y in 0...levelHeight)
      {
        if(rooms[y][x] != 0)
        {
          p1 = new Point(x, y);
          break;
        }
      }
    }

    if(p1 == null)
    {
        return;
    }

    for (x in 0...levelWidth)
    {
      if(p2 != null)
      {
        break;
      }
      for (y in 0...levelHeight)
      {
        if(
          rooms[y][x] != 0
          && rooms[y][x] != rooms[Math.round(p1.y)][Math.round(p1.x)]
        ) {
          p2 = new Point(x, y);
          break;
        }
      }
    }

    if(p2 == null)
    {
        return;
    }

    var p1Start:Point = p1.clone();
    var p2Start:Point = p2.clone();

    // Get P2 and P2 as close as possible to each other as possible without
    // leaving the rooms they're in
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (rooms[y][x] == rooms[Math.round(p1.y)][Math.round(p1.x)]) {
          if (Point.distance(p1, p2) > Point.distance(p2, new Point(x, y))) {
            p1 = new Point(x, y);
          }
        }
      }
    }

    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if (rooms[y][x] == rooms[Math.round(p2.y)][Math.round(p2.x)]) {
          if (Point.distance(p1, p2) > Point.distance(p1, new Point(x, y))) {
            p2 = new Point(x, y);
          }
        }
      }
    }

    // Dig a tunnel between the two points
    var pDig:Point = new Point(p1.x, p1.y);
    pDig = movePointTowardsPoint(pDig, p2);
    while (!pDig.equals(p2))
    {
      map[Math.round(pDig.y)][Math.round(pDig.x)] = 0;
      pDig = movePointTowardsPoint(pDig, p2);
    }

    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
        if(rooms[y][x] == rooms[Math.round(p2Start.y)][Math.round(p2Start.x)])
        {
          rooms[y][x] = rooms[Math.round(p1Start.y)][Math.round(p1Start.x)];
        }
      }
    }

    connectRooms(rooms);
  }

  public function movePointTowardsPoint(movePoint:Point, towardsPoint:Point)
  {
    if (movePoint.x < towardsPoint.x) {
      movePoint.x = movePoint.x + 1;
    } else if (movePoint.x > towardsPoint.x) {
      movePoint.x = movePoint.x - 1;
    } else if (movePoint.y < towardsPoint.y) {
      movePoint.y = movePoint.y + 1;
    } else if (movePoint.y > towardsPoint.y) {
      movePoint.y = movePoint.y - 1;
    }
    return movePoint;
  }

  public function pickRandomPoint()
  {
    var randomPoint = new Point(
      Math.floor(Math.random()*levelWidth),
      Math.floor(Math.random()*levelHeight)
    );
    return randomPoint;
  }

  public function pickRandomOpenPoint()
  {
    var randomOpenPoint:Point = pickRandomPoint();
    while(
      map[Math.round(randomOpenPoint.y)][Math.round(randomOpenPoint.x)] != 0
    ) {
      randomOpenPoint = pickRandomPoint();
    }
    return randomOpenPoint;
  }

  public function pickRandomPointOnGround()
  {
    var randomPoint:Point = pickRandomPoint();
    while(
      map[Math.round(randomPoint.y)][Math.round(randomPoint.x)] != 0 ||
      map[Math.round(randomPoint.y) + 1][Math.round(randomPoint.x)] != 1 ||
      map[Math.round(randomPoint.y) + 1][Math.round(randomPoint.x) + 1] != 1 ||
      map[Math.round(randomPoint.y) + 1][Math.round(randomPoint.x) - 1] != 1 ||
      map[Math.round(randomPoint.y)][Math.round(randomPoint.x) + 1] != 0 ||
      map[Math.round(randomPoint.y)][Math.round(randomPoint.x) - 1] != 0
    ) {
      randomPoint = pickRandomOpenPoint();
    }
    randomPoint.y += 1;
    return randomPoint;
  }

  public function pickRandomOpenPointWithRoom(roomNeeded:Int)
  {
    var randomOpenPoint:Point = pickRandomPoint();
    while(
      !isInMap(Math.round(randomOpenPoint.x) + roomNeeded, Math.round(randomOpenPoint.y) + roomNeeded) ||
      map[Math.round(randomOpenPoint.y)][Math.round(randomOpenPoint.x)] != 0
    ) {
      randomOpenPoint = pickRandomPoint();
    }
    return randomOpenPoint;
  }

  public function isInMap(checkX:Int, checkY:Int) {
      return checkX >= 0 && checkX < levelWidth && checkY >= 0 && checkY < levelHeight;
    }

  public function createSubLevel()
  {
    var point = pickRandomOpenPointWithRoom(50);
    var largestRect = [
      "x"=>Math.round(point.x), "y"=>Math.round(point.y),
      "width"=>50, "height"=>50
    ];
    for(x in 0...largestRect["width"]) {
      for(y in 0...largestRect["height"]) {
        map[largestRect["y"] + y][largestRect["x"] + x] = 0;
      }
    }
    var largestSpace = new DebugSquare(
      largestRect["x"] * TILE_SIZE * levelScale,
      largestRect["y"] * TILE_SIZE * levelScale,
      largestRect["width"] * TILE_SIZE * levelScale,
      largestRect["height"] * TILE_SIZE * levelScale
    );
    entities.push(largestSpace);
    var subLevel = new ProcLevel(
      largestRect["x"] * TILE_SIZE * levelScale,
      largestRect["y"] * TILE_SIZE * levelScale,
      largestRect["width"],
      largestRect["height"],
      1,
      false
    );
    entities.push(subLevel);
  }

}
