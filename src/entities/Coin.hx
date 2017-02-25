package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import scenes.*;

class Coin extends Entity
{
    public function new(x:Int, y:Int)
    {
      super(x, y);
      graphic = new Image("graphics/coin.png");
      setHitbox(8, 14, -3 -1);
    }

    override public function update()
    {
      if(collide("player", x, y) != null) {
        HXP.scene.remove(this);
      }
      super.update();
    }
}
