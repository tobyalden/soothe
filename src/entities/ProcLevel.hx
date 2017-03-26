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
  public static inline var LEVEL_SCALE = 3;
  public static inline var TILE_AND_LEVEL_SCALE = TILE_SIZE * LEVEL_SCALE;
  public static inline var BIGGIFY_SCALE = 5;

  public static inline var OFFSET_CHANCE = 0.01;
  public static inline var FILL_CHANCE = 0.75;
  public static inline var DETAIL_REPEAT = 5;
  public static inline var OFFSET_SIZE = 5;

  private var map:Array<Array<Int>>;
  private var tiles:Tilemap;
  private var collisionMask:Grid;
  public var entities:Array<Entity>;

  public var levelWidth:Int;
  public var levelHeight:Int;
  public var entrance:Exit;
  public var xOffset:Float;
  public var yOffset:Float;

  public function new(levelWidth:Int, levelHeight:Int, entrance:Exit) {
    this.levelWidth = levelWidth;
    this.levelHeight = levelHeight;
    this.entrance = entrance;
    setLevelOffset();
    super(xOffset, yOffset);
    map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
    entities = new Array<Entity>();
    generateLevel();
    addEntitiesToScene();
  }

  public function addEntitiesToScene() {
    for (entity in entities) {
      entity.x += xOffset;
      entity.y += yOffset;
      HXP.scene.add(entity);
    }
  }

  public function setLevelOffset() {
    xOffset = 0;
    yOffset = 0;
    if(entrance == null) {
      return;
    }
    if(entrance.getSide() == Exit.TOP) {
      yOffset = entrance.y - levelHeight * TILE_AND_LEVEL_SCALE * BIGGIFY_SCALE;
    }
    else if(entrance.getSide() == Exit.BOTTOM) {
      yOffset = entrance.y + entrance.height;
    }
  }

  public function finishInitializing()
  {
    tiles.scale = LEVEL_SCALE;
    tiles.smooth = false;
    graphic = tiles;
    tiles.loadFrom2DArray(map);
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
                if(offsetX >= 0 && offsetX < levelWidth && offsetY >= 0 && offsetY < levelHeight) {
                  map[offsetY][offsetX] = fill;
                }
            }
          }
        }
      }
    }
  }

  public function generateLevel() {
    randomizeMap();
    connectAndContainAllRooms();
    createBoundaries();
    biggifyMap();
    for (i in -Math.round(DETAIL_REPEAT/2)...Math.round(DETAIL_REPEAT/2)) {
      detailMap(OFFSET_SIZE + i - 1);
    }
    /*connectAndContainAllRooms();*/
    widenPassages();
    removeFloaters();
    createBoundaries();
    tiles = new Tilemap("graphics/stone.png", TILE_SIZE * this.levelWidth, TILE_SIZE * this.levelHeight, TILE_SIZE, TILE_SIZE);
    placeWater();
    placeCoins();
    placeExits();
    if(entrance == null) {
      placePlayers();
    }
    prettifyMap();
    finishInitializing();
  }

  public function placeCoins() {
    for(i in 0...100) {
      var openPoint = pickRandomOpenPoint();
      entities.push(new Coin(Std.int(openPoint.x) * TILE_AND_LEVEL_SCALE, Std.int(openPoint.y) * TILE_AND_LEVEL_SCALE));
    }
  }

  public function placePlayers() {
			entities.push(new Player(300, 0, 1));
			entities.push(new Player(300 + 50, 0, 2));
			entities.push(new Player(300 + 100, 0, 3));
			entities.push(new Ball(0, 0));
	}

  public function placeExits() {
    for (x in 10...20)
    {
      for (y in 0...levelHeight)
      {
        map[y][x] = 0;
      }
    }
    entities.push(new HoverTube(10 * TILE_AND_LEVEL_SCALE, 0, 10 * TILE_AND_LEVEL_SCALE, levelHeight * TILE_AND_LEVEL_SCALE));
    if(entrance == null) {
      entities.push(new Exit(10 * TILE_AND_LEVEL_SCALE, levelHeight * TILE_AND_LEVEL_SCALE, 10 * TILE_AND_LEVEL_SCALE, TILE_AND_LEVEL_SCALE * 10, Exit.BOTTOM));
      entities.push(new Exit(10 * TILE_AND_LEVEL_SCALE, -TILE_AND_LEVEL_SCALE * 10, 10 * TILE_AND_LEVEL_SCALE, TILE_AND_LEVEL_SCALE * 10, Exit.TOP));
    }
    else if(entrance.getSide() != Exit.TOP) {
      entities.push(new Exit(10 * TILE_AND_LEVEL_SCALE, levelHeight * TILE_AND_LEVEL_SCALE, 10 * TILE_AND_LEVEL_SCALE, TILE_AND_LEVEL_SCALE * 10, Exit.BOTTOM));
    }
    else if(entrance.getSide() != Exit.BOTTOM) {
      entities.push(new Exit(10 * TILE_AND_LEVEL_SCALE, -TILE_AND_LEVEL_SCALE * 10, 10 * TILE_AND_LEVEL_SCALE, TILE_AND_LEVEL_SCALE * 10, Exit.TOP));
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
              x * TILE_AND_LEVEL_SCALE,
              y * TILE_AND_LEVEL_SCALE + 8,
              TILE_AND_LEVEL_SCALE * scanX,
              TILE_AND_LEVEL_SCALE - 8
            );
            entities.push(water);
          }
        }
      }
    }

  }

  public function biggifyMap() {
    var bigMap = [for (y in 0...levelHeight * BIGGIFY_SCALE) [for (x in 0...levelWidth * BIGGIFY_SCALE) 0]];
    for (x in 0...levelWidth)
    {
      for (y in 0...levelHeight)
      {
          for(scaleX in 0...BIGGIFY_SCALE)
          {
              for(scaleY in 0...BIGGIFY_SCALE)
              {
                  bigMap[y * OFFSET_SIZE + scaleY][x * OFFSET_SIZE + scaleX] = map[y][x];
              }
          }
      }
    }
    levelWidth = levelWidth * BIGGIFY_SCALE;
    levelHeight = levelHeight * BIGGIFY_SCALE;
    map = bigMap;
  }

  public function connectAndContainAllRooms()
  {
    createBoundaries();
    var rooms:Array<Array<Int>> = getRooms();
    connectRooms(rooms);
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

  public function emptyMap()
    {
      map = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
    }

    public function randomizeMap()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          map[y][x] = Math.round(Math.random() * 0.7);
        }
      }
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
      var rooms:Array<Array<Int>> = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
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

    public function openSides()
    {
      for (x in 0...levelWidth)
      {
        for (y in 0...levelHeight)
        {
          if ((x == 0 || x == levelWidth-1) && y == levelHeight/2)
          {
            var digX:Int = x;
            while(map[y][digX] != 0)
            {
              map[y][digX] = 0;
              if(x == 0)
              {
                digX++;
              }
              else if (x == levelWidth-1) {
                digX--;
              }
            }
          }
          else if ((y == 0 || y == levelHeight-1) && x == levelWidth/2)
          {
            var digY:Int = y;
            while(map[digY][x] != 0)
            {
              map[digY][x] = 0;
              if(y == 0)
              {
                digY++;
              }
              else if (y == levelHeight-1) {
                digY--;
              }
            }
          }
        }
      }
    }

    public function getRooms()
    {
      var roomCount:Int = 0;
      var rooms:Array<Array<Int>> = [for (y in 0...levelHeight) [for (x in 0...levelWidth) 0]];
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

    public function openRandomSpace()
    {
      var randomPoint:Point = pickRandomPoint();
      var rooms:Array<Array<Int>> = getRooms();
      while (map[Math.round(randomPoint.y)][Math.round(randomPoint.x)] == 0) {
        randomPoint = pickRandomPoint();
      }
      openRandomSpaceHelper(Math.round(randomPoint.x), Math.round(randomPoint.y));
    }

    public function openRandomSpaceHelper(x:Int, y:Int)
    {
      if (isWithinMap(x, y) && map[y][x] == 1) {
        map[y][x] = 0;
        openRandomSpaceHelper(x + 1, y);
        openRandomSpaceHelper(x - 1, y);
        openRandomSpaceHelper(x, y + 1);
        openRandomSpaceHelper(x, y - 1);
      }
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
      // I should make it so it just picks all the points in one go...!
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
          if(rooms[y][x] != 0 && rooms[y][x] != rooms[Math.round(p1.y)][Math.round(p1.x)])
          {
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

      // Get P2 and P2 as close as possible to each other as possible without leaving the rooms they're in
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
      var randomPoint = new Point(Math.floor(Math.random()*levelWidth), Math.floor(Math.random()*levelHeight));
      return randomPoint;
    }

    public function pickRandomOpenPoint()
    {
      var randomOpenPoint:Point = pickRandomPoint();
      while(map[Math.round(randomOpenPoint.y)][Math.round(randomOpenPoint.x)] != 0)
      {
        randomOpenPoint = pickRandomPoint();
      }
      return randomOpenPoint;
    }

  public function prettifyMap()
  {
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

}
