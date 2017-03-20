package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class HoverTube extends Entity
{
    public function new(x:Int, y:Int, width:Int, height:Int)
    {
        super(x, y);
        graphic = new TiledImage("graphics/hovertube.png", width, height);
        setHitbox(width, height);
        type = "hovertube";
    }
}
