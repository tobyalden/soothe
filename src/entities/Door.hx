package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import scenes.*;

class Door extends Entity
{

    private var sprite:Spritemap;

    public function new(x:Int, y:Int)
    {
        super(x, y - 32);
        sprite = new Spritemap("graphics/door.png", 32, 32);
        sprite.add("closed", [0]);
        sprite.add("open", [1]);
        sprite.play("closed");
        graphic = sprite;
        setHitbox(16, 16, -8, -16);
        layer = 9999;
    }

    override public function update() {
      var player = cast(scene.getInstance("player1"), Player);
      if(player.isInteracting && collideWith(player, x, y) != null) {
        sprite.play("open");
        cast(scene, GameScene).transitionToNewScene();
      }
    }

}
