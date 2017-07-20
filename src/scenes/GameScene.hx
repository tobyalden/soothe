package scenes;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
import com.haxepunk.screen.*;
import entities.*;

class GameScene extends Scene
{

	private var level:ProcLevel;
	private var transition:Transition;

	public function new()
	{
		super();
	}

	/*
		- true seamless (not sure if loading times would make this awkward, both generating and loading from memory)
			let's be real, true seamless would open up a can of worms - would have to write coroutines to load entities gradually, probably.
		- airlock style
		- arbitary, multidirectional tree style (would this ruin sense of contigious space...?)
		- doors w/ transitions (e.g. cave story)... or just "walk off to left" and there's a pagefold transition style
	*/

	public override function begin()
	{
    level = new ProcLevel(0, 0, 25, 25, 3, false);
		transition = new Transition();
		add(level);
		add(transition);
	}

  public override function update() {
		Timer.updateAll();
		if(Input.pressed(Key.L)) {
			/*add(new Luster(Math.round(level.player.x - 500), Math.round(level.player.y)));*/
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
