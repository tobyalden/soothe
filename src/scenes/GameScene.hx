package scenes;

import com.haxepunk.*;
import entities.*;

class GameScene extends Scene
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
    var level:ProcLevel = new ProcLevel(40, 30);
		add(level);
		for (entity in level.entities) {
			add(entity);
		}
	}

}
