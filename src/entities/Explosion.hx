package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Explosion extends ActiveEntity
{
    public function new(source:Entity)
    {
        super(0, 0);
        this.sprite = new Spritemap("graphics/explosion.png", 41, 41);
        x = source.centerX;
        y = source.centerY;
        sprite.add("explode", [0, 1, 2, 3, 4, 5, 6], 24, false);
        sprite.play("explode");
        setHitbox(41, 41);
        centerOrigin();
        finishInitializing();
        // This is a workaround for a bug in HaxePunk with centerGraphicInRect
        graphic.x = -halfWidth;
        graphic.y = -halfHeight;
    }

    override public function update()
    {
        super.update();
        if(sprite.complete) {
          scene.remove(this);
        }
    }
}
