package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Water extends Entity
{
    public function new(x:Int, y:Int, width:Int, height:Int)
    {
        super(x, y);
        graphic = new TiledImage("graphics/water.png", width, height);
        setHitbox(width, height);
        type = "water";
    }

    override public function update() {
        super.update();
        if(collide("hovertube", x, y) != null) {
            HXP.scene.remove(this);
        }
    }

}
