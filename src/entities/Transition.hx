package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Transition extends Entity
{

    public var sprite:TiledSpritemap;

    public function new()
    {
            super(0, 0);
            this.sprite = new TiledSpritemap("graphics/transition.png", 32, 32, HXP.width, HXP.height);
            layer = -9999;
            followCamera = true;
            visible = false;
            sprite.add("fadeout", [9, 9, 9, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], 15, false);
            sprite.add("fadein", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 15, false);
            graphic = sprite;
            setHitbox(width, height);
    }

    override public function update()
    {
        super.update();
        if(sprite.currentAnim == "fadein" && sprite.complete) {
            visible = false;
        }
    }

    public function fadeOut()
    {
        visible = true;
        sprite.play("fadeout");
    }

    public function fadeIn()
    {
        visible = true;
        sprite.play("fadein");
    }

}
