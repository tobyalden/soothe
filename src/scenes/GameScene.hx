package scenes;

import flash.system.System;
import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
import com.haxepunk.screen.*;
import entities.*;

class GameScene extends Scene
{

	private var level:ProcLevel;
	private var transition:Transition;
	public var paused:Bool;
	public var isTransitioning:Bool;

	public function new()
	{
		super();
	}

	public override function begin()
	{
        this.level = new ProcLevel(0, 0, 25, 25, 3);
		this.transition = new Transition();
		this.paused = false;
		this.isTransitioning = false;
		add(level);
		add(transition);
		transition.fadeIn();
	}

  public override function update() {
	debugTools();
	Timer.updateAll();
	if(isTransitioning && transition.sprite.complete) {
		HXP.scene = new GameScene();
	}
	Luster.offsetDestinationForGroup();
	super.update();
  }

	public function debugTools()
	{
	    if(Input.pressed(Key.L)) {
			pause();
		}
		if(Input.pressed(Key.P)) {
			HXP.scene = new GameScene();
		}
		if(Input.pressed(Key.ESCAPE)) {
			System.exit(0);
		}

		if(Input.check(Key.DIGIT_0)) {
			HXP.screen.scale = Math.max(0.1, HXP.screen.scale - 0.025);
		}
		else {
			HXP.screen.scale = 4;
		}
	}

	public function pause()
	{
		paused = !paused;
		for(e in level.entities) {
			e.active = !paused;
		}
	}

	public function transitionToNewScene()
	{
		isTransitioning = true;
		level.player.sprite.stop();
		pause();
		transition.fadeOut();
	}


}
