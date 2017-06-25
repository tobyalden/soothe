package entities;

import com.haxepunk.graphics.*;
import flash.geom.Point;

class Missile extends Bullet {

  public function new(x:Float, y:Float, velocity:Point)
  {
      super(x, y, velocity);
      type = "bullet";
      graphic = new Image("graphics/missile.png");
      setHitboxTo(graphic);
  }
}
