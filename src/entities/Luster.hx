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

    public static inline var GROUP_SPACING = 40;
    public static inline var ACTIVATE_RADIUS = 200;

    private static var groupLogicApplied:Bool = false;

    public var bobTimer:Float;
    public var destination:Point;
    private var cooldownTimer:Int;
    private var isActive:Bool;

    public function new(x:Int, y:Int)
    {
        super(x, y);
        sprite = new Spritemap("graphics/luster.png", 16, 16);
        sprite.scale = 1.5;
        cooldownTimer = 0;
        bobTimer = 0;
        destination = new Point(0, 0);
        flashColor = 0xFFFFFF;
        isActive = false;
        setHitbox(24, 24);
        sprite.add("idle", [0]);
        sprite.add("shoot", [1]);
        sprite.play("idle");
        type = "enemy";
        finishInitializing();
    }

    public function offsetDestinationForGroup()
    {
      // later factor in distance & make it only run once per frame
      var allLusters = new Array<Luster>();
      scene.getClass(Luster, allLusters);
      var count = 0;
      for(luster in allLusters) {
        if(isActive) {
          continue;
        }
        if(count == 0) {
          // do nothing
        }
        else if(count % 2 == 0) {
          luster.destination.x += Math.ceil(count/2) * GROUP_SPACING;
          luster.destination.y -= Math.ceil(count/2) * GROUP_SPACING;
        }
        else {
          luster.destination.x += Math.ceil(count/2) * -GROUP_SPACING;
          luster.destination.y -= Math.ceil(count/2) * GROUP_SPACING;
        }
        count++;
      }
    }

    public override function update()
    {
      var player = HXP.scene.getInstance("player1");
      destination.x = player.centerX - halfWidth;
      destination.y = player.centerY - halfHeight - HOVER_HEIGHT;
      if(distanceFrom(player, true) <= ACTIVATE_RADIUS) {
        isActive = true;
      }
      offsetDestinationForGroup();
      if(isActive) {
        moveTowards(destination.x, destination.y, CHASE_SPEED);
      }
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
      if(collide("sword", x, y) != null) {
        die();
      }
      var bullet = collide("bullet", x, y);
      if(bullet != null) {
        takeDamage(50);
        scene.remove(bullet);
      }
      super.update();
    }

    override public function die() {
      scene.add(new Explosion(this));
      scene.remove(this);
    }

    override public function takeDamage(damage:Int) {
      health -= damage;
      isActive = true;
      startFlashing();
      damageFlash.restart();
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
