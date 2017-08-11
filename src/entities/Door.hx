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
    this.sprite = new Spritemap("graphics/door.png", 32, 32);
    layer = 99;
    sprite.add("closed", [0]);
    sprite.add("open", [1]);
    sprite.play("closed");
    graphic = sprite;
    setHitbox(16, 16, -8, -16);
  }

  override public function update() {
    var player = cast(scene.getInstance("player"), Player);
    if(player.isInteracting && collideWith(player, x, y) != null) {
      sprite.play("open");
      cast(scene, GameScene).transitionToNewScene();
    }
  }

}
