package entities;

import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.Entity;

class Level extends TmxEntity
{

  public static inline var PLAYER = 17;
  public static inline var COIN = 18;

  public var entities:Array<Entity>;

  public function new(filename:String)
  {
      super(filename);
      entities = new Array<Entity>();
      map = TmxMap.loadFromFile(filename);
      loadGraphic("graphics/tiles.png", ["main"]);
      loadMask("main", "walls");
      for(entity in map.getObjectGroup("entities").objects)
      {
        if(entity.gid == PLAYER)
        {
          entities.push(new Player(entity.x, entity.y, false));
          entities.push(new Player(entity.x + 20, entity.y, true));
        }
        if(entity.gid == COIN)
        {
          entities.push(new Coin(entity.x, entity.y - 16));
        }
      }
  }

}
