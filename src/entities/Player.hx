package entities;

import flash.system.System;
import com.haxepunk.utils.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Player extends ActiveEntity
{

  public static inline var SPEED = 1;

	public function new(x:Int, y:Int)
	{
		super(x, y);
    sprite = new Spritemap("graphics/player.png", 16, 16);
    sprite.add("down", [0, 1], 6);
    sprite.add("right", [2, 3], 6);
    sprite.add("left", [4, 5], 6);
    sprite.add("up", [6, 7], 6);
    sprite.add("roll", [6, 8, 9, 10], 6);
    sprite.play("down");
    setHitbox(11, 15, -3, -1);
		finishInitializing();
	}

  public override function update()
  {
    if(Input.check(Key.LEFT)) {
      velocity.x = -SPEED;
    }
    else if(Input.check(Key.RIGHT)) {
      velocity.x = SPEED;
    }
    else {
      velocity.x = 0;
    }
    if(Input.check(Key.UP)) {
      velocity.y = -SPEED;
    }
    else if(Input.check(Key.DOWN)) {
      velocity.y = SPEED;
    }
    else {
      velocity.y = 0;
    }

    moveBy(velocity.x, velocity.y, "walls");

    if(Input.check(Key.ESCAPE)) {
      System.exit(0);
    }

    animate();

    super.update();
  }

  private function animate()
  {
    if(velocity.x > 0) {
      sprite.play("right");
    }
    else if(velocity.x < 0) {
      sprite.play("left");
    }
    else if(velocity.y > 0) {
      sprite.play("down");
    }
    else if(velocity.y < 0) {
      sprite.play("up");
    }
    else {
      sprite.stop();
    }
  }
}
