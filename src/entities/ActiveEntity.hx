package entities;

import flash.geom.Point;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;

class ActiveEntity extends Entity
{

    public static inline var DEFAULT_FLASH_COLOR = 0xFFFFFF;
    public static inline var DEFAULT_FLASH_SPEED = 0.2;
    public static inline var DAMAGE_FLASH_DURATION = 10;

    public var sprite:Spritemap;
    private var velocity:Point;
    private var flashColor:Int;
    private var flashTimer:Float;
    private var isFlashing:Bool;
    private var health:Int;
    private var damageFlash:Timer;

    public function new(x:Int, y:Int, health:Int=100)
    {
        super(x, y);
        this.sprite = null;
        this.velocity = new Point(0, 0);
        this.flashColor = DEFAULT_FLASH_COLOR;
        this.flashTimer = 0;
        this.isFlashing = false;
        this.health = health;
        this.damageFlash = new Timer(DAMAGE_FLASH_DURATION);
    }

    public function finishInitializing()
    {
      sprite.smooth = false;
      graphic = sprite;
    }

    public override function update()
    {
        super.update();
        if(!damageFlash.isActive() && isFlashing) {
          stopFlashing();
        }
        if(isFlashing) {
          if(flashTimer%Math.PI < 1) {
            visible = false;
          }
          else {
            visible = true;
          }
          flashTimer += DEFAULT_FLASH_SPEED;
          if(flashTimer > Math.PI*4) {
            flashTimer -= Math.PI*4;
          }
          sprite.color = HXP.colorLerp(flashColor, 0xFFFFFF, Math.abs(Math.sin(flashTimer)));
        }
        else {
          flashTimer = 0;
        }
        if(health <= 0) {
          die();
        }
    }

    public function startFlashing()
    {
      flashTimer = 0;
      isFlashing = true;
    }

    public function stopFlashing()
    {
      isFlashing = false;
      sprite.color = 0xFFFFFF;
      visible = true;
    }

    public function takeDamage(damage:Int) {
      health -= damage;
      startFlashing();
      damageFlash.restart();
    }

    public function die() {
      scene.remove(this);
    }


    private function unstuck()
    {
        while(collide('walls', x, y) != null)
        {
          moveBy(0, -10);
        }
    }

    private function isOnGround()
    {
        return collide("walls", x, y + 1) != null;
    }

    private function isOnCeiling()
    {
        return collide("walls", x, y - 1) != null;
    }

    private function isOnWall()
    {
        return (
          collide("walls", x - 1, y) != null ||
          collide("walls", x + 1, y) != null
        );
    }

    private function isOnRightWall()
    {
        return collide("walls", x + 1, y) != null;
    }

    private function isOnLeftWall()
    {
        return collide("walls", x - 1, y) != null;
    }

}
