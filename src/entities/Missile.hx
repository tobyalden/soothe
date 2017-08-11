package entities;

import com.haxepunk.graphics.*;
import flash.geom.Point;
import com.haxepunk.*;

class Missile extends Entity {

    private var velocity:Point;

    public function new(x:Float, y:Float, velocity:Point)
    {
        super(x, y);
        this.velocity = velocity;
        type = "missile";
        var image = new Image("graphics/missile.png");
        image.smooth = false;
        graphic = image;
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
        moveBy(velocity.x, velocity.y, ["walls", "sword"]);
        super.update();
    }

}
