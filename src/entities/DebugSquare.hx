package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class DebugSquare extends Entity
{
    public function new(x:Int, y:Int, width:Int, height:Int)
    {
        super(x, y);
        graphic = Image.createRect(width, height, 0xFF0000, 0.5);
        setHitbox(width, height);
        layer = -9999;
    }
}
