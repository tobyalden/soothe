package entities;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.Sfx;
import flash.geom.Point;

class Bullet extends Entity
{

    public static inline var BULLET_POWER = 10;
    public static inline var GRAVITY = 0.025;

    private var velocity:Point;

    public function new(x:Float, y:Float, velocity:Point)
    {
        super(x, y);
        this.velocity = velocity;
        type = "bullet";
        graphic = Image.createRect(3, 3);
        setHitboxTo(graphic);
    }

    public override function moveCollideX(e:Entity)
    {
        scene.remove(this);
        return true;
    }

    public override function moveCollideY(e:Entity)
    {
        scene.remove(this);
        return true;
    }

    public override function update()
    {
        super.update();
        moveBy(velocity.x, velocity.y, "walls");
        /*velocity.y += GRAVITY;*/
        var enemy = collide('enemy', x, y);
        if(enemy != null)
        {
          scene.remove(this);
        }
    }
}
