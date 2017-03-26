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
    var level:ProcLevel = new ProcLevel(100, 7, null);
		add(level);
		level.addEntitiesToScene();
		placePlayers();
	}

	public function placePlayers() {
			add(new Player(300, 0, 1));
			add(new Player(300 + 50, 0, 2));
			add(new Player(300 + 100, 0, 3));
			add(new Ball(0, 0));
	}


  public override function update() {
    if(Input.pressed(Key.P)) {
      HXP.scene = new GameScene();
    }
    super.update();
  }


}
