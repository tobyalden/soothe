package scenes;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.screen.*;
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
		Timer.updateAll();
		if(Input.pressed(Key.L)) {
			add(new Luster(Math.round(level.player.x - 500), Math.round(level.player.y)));
		}
    if(Input.pressed(Key.P)) {
      HXP.scene = new GameScene();
    }
		if(Input.check(Key.DIGIT_0)) {
			HXP.screen.scale = Math.max(0.1, HXP.screen.scale - 0.025);
		}
		else {
			HXP.screen.scale = 4;
		}
    super.update();
  }


}
