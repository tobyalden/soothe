package scenes;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import entities.*;

class GameScene extends Scene
{

	private var level:ProcLevel;

	public function new()
	{
		super();
	}

	public override function begin()
	{
    level = new ProcLevel(0, 0, 25, 25, 3, false);
		add(level);
	}

  public override function update() {
    if(Input.pressed(Key.P)) {
      HXP.scene = new GameScene();
    }
    super.update();
  }


}
