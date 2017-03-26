package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Exit extends Entity
{
    public static inline var NONE = 0;
    public static inline var TOP = 1;
    public static inline var BOTTOM = 2;
    public static inline var LEFT = 3;
    public static inline var RIGHT = 4;

    private var side:Int;
    private var activated:Bool;

    public function new(x:Int, y:Int, width:Int, height:Int, side:Int)
    {
        super(x, y);
        this.side = side;
        activated = true;
        graphic = new TiledImage("graphics/exit.png", width, height);
        setHitbox(width, height);
        layer = -10;
        type = "exit";
    }

    public function getSide() {
      return side;
    }

    public function isActivated() {
      return activated;
    }

    public function deactivate() {
      activated = false;
      graphic = new TiledImage("graphics/exit-deactivated.png", width, height);
    }
}
