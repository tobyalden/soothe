package scenes;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import entities.*;

class GameScene extends Scene
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
    var level:ProcLevel = new ProcLevel(100, 7);
		add(level);
		for (entity in level.entities) {
			add(entity);
		}
	}

  public override function update() {
    if(Input.pressed(Key.P)) {
      HXP.scene = new GameScene();
    }
    super.update();
  }


}
