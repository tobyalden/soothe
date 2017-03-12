package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import scenes.*;

class Ball extends ActiveEntity
{
    public static inline var GRAVITY = 0.25;
    public static inline var BOUNCE_DECAY = 1.75;
    public static inline var KICK_UPLIFT = 3.5;
    public static inline var MAX_VELOCITY = 7;

    public function new(x:Int, y:Int)
    {
      super(x, y);
      graphic = Image.createCircle(8, 0xFF0000);
      setHitboxTo(graphic);
      name = "ball";
    }

    override public function update()
    {
      velocity.y += GRAVITY;
      var _player = collide("player", x, y);
      if(_player != null) {
        var player = cast(_player, Player);
        if(player.velocity.x != 0) {
          velocity.y += player.velocity.y - KICK_UPLIFT;
        }
        velocity.x += player.velocity.x * 2;
      }
      capVelocity();
      moveBy(velocity.x, velocity.y, "walls");
      super.update();
    }

    public function capVelocity() {
      velocity.x = Math.min(velocity.x, MAX_VELOCITY);
      velocity.y = Math.min(velocity.y, MAX_VELOCITY);
      velocity.x = Math.max(velocity.x, -MAX_VELOCITY);
      velocity.y = Math.max(velocity.y, -MAX_VELOCITY);
    }

    override public function moveCollideY(e:Entity) {
      velocity.y = -velocity.y/BOUNCE_DECAY;
      return true;
    }

    override public function moveCollideX(e:Entity) {
      velocity.x = -velocity.x/4;
      return true;
    }
}
