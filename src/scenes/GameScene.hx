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
    var level:ProcLevel = new ProcLevel(40, 7, null);
		add(level);
	}

  public override function update() {
    if(Input.pressed(Key.P)) {
      HXP.scene = new GameScene();
    }
    super.update();
  }


}
