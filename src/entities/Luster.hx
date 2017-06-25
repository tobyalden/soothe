package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import flash.geom.Point;

class Luster extends ActiveEntity
{

    public static inline var CHASE_SPEED = 1;
    public static inline var HOVER_HEIGHT = 100;
    public static inline var BOB_SPEED = 0.3;
    public static inline var BOB_HEIGHT = 1;
    public static inline var MISSILE_SPEED = 6;
    public static inline var SHOT_COOLDOWN = 20;

    public var bobTimer:Float;
    public var destination:Point;
    private var cooldownTimer:Int;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        sprite = new Spritemap("graphics/luster.png", 16, 16);
        sprite.scale = 1.5;
        cooldownTimer = 0;
        bobTimer = 0;
        destination = new Point(0, 0);
        setHitbox(24, 24);
        sprite.add("idle", [0]);
        sprite.add("shoot", [1]);
        sprite.play("idle");
        finishInitializing();
    }

    public override function update()
    {
      var player = HXP.scene.getInstance("player1");
      destination.x = player.centerX - halfWidth;
      destination.y = player.centerY - halfHeight - HOVER_HEIGHT;
      moveTowards(destination.x, destination.y, CHASE_SPEED);
      if(distanceToPoint(destination.x, destination.y, true) < 50) {
        sprite.play("shoot");
        shoot();
      }
      else {
        sprite.play("idle");
      }
      y += Math.sin(bobTimer) * BOB_HEIGHT;
      bobTimer += BOB_SPEED;
      if(bobTimer > Math.PI*4) {
        bobTimer -= Math.PI*4;
      }
      super.update();
    }

    private function shoot()
    {
      if(cooldownTimer > 0) {
        cooldownTimer -= 1;
      }
      else {
        scene.add(new Missile(centerX - 6, centerY, new Point(0, MISSILE_SPEED)));
        cooldownTimer = SHOT_COOLDOWN;
      }
    }

}
