package entities;

import com.haxepunk.graphics.*;
import flash.geom.Point;
import com.haxepunk.*;

class Missile extends Bullet {

  public function new(x:Float, y:Float, velocity:Point)
  {
      super(x, y, velocity);
      type = "missile";
      var image = new Image("graphics/missile.png");
      image.smooth = false;
      graphic = image;
      setHitboxTo(graphic);
  }

  public override function moveCollideX(e:Entity)
  {
    if(e.type == "walls" || e.type == "player") {
      scene.remove(this);
    }
    return true;
  }

  public override function moveCollideY(e:Entity)
  {
      if(e.type == "walls" || e.type == "player") {
        scene.remove(this);
      }
      return true;
  }

}
