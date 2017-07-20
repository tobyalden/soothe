package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Door extends Entity
{

    private var sprite:Spritemap;

    public function new(x:Int, y:Int)
    {
        super(x, y - 32);
        sprite = new Spritemap("graphics/door.png", 32, 32);
        sprite.add("closed", [0]);
        sprite.add("open", [0]);
        sprite.play("closed");
        graphic = sprite;
        setHitboxTo(sprite);
        layer = 9999;
    }

}
