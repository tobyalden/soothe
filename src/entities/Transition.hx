package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Transition extends Entity
{

    private var sprite:TiledSpritemap;

    public function new()
    {
        super(0, 0);
        sprite = new TiledSpritemap("graphics/transition.png", 64, 64, HXP.width, HXP.height);
        sprite.add("fadeout", [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], 6, false);
        sprite.add("fadein", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 6, false);
        graphic = sprite;
        followCamera = true;
        visible = false;
        setHitbox(width, height);
        layer = -9999;
    }

    public function fadeOut()
    {
      visible = true;
      sprite.play("fadeout");
    }

}
