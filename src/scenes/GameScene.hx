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
    var level:Level = new Level("levels/cave.tmx");
		add(level);
		for (entity in level.entities) {
			add(entity);
		}
	}

}
