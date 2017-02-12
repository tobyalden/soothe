package entities;

import flash.system.System;
import com.haxepunk.utils.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;

class Player extends ActiveEntity
{

  public static inline var WALK_SPEED = 2.5;
  public static inline var WALK_ACCEL = 0.28;
  public static inline var RUN_SPEED = 2 * 2;
  public static inline var RUN_ACCEL = 0.15;
  public static inline var STOP_DECCEL = 0.3;
  public static inline var AIR_ACCEL = 0.18;
  public static inline var JUMP_POWER = 6;
  public static inline var JUMP_CANCEL_POWER = 3;
  public static inline var GRAVITY = 0.25;
  public static inline var MAX_FALL_SPEED = 3;
  public static inline var SKID_MULTIPLIER = 1;

	public function new(x:Int, y:Int)
	{
		super(x, y);
    sprite = new Spritemap("graphics/player.png", 16, 24);
    sprite.add("idle", [0]);
    sprite.add("walk", [1, 2, 3, 2], 10);
    sprite.add("run", [1, 2, 3, 2], 13);
    sprite.add("jump", [4]);
    sprite.add("wallslide", [5]);
    sprite.add("skid", [6]);
    sprite.play("idle");
    setHitbox(12, 24, -2, 0);
		finishInitializing();
	}

  private function isChangingDirection() {
    return (
      Input.check(Key.LEFT) && velocity.x > 0 ||
      Input.check(Key.RIGHT) && velocity.x < 0
    );
  }

  public override function update()
  {
    var skidMultiplier = 1.0;
    if(isOnGround() && isChangingDirection()) {
      skidMultiplier = SKID_MULTIPLIER;
    }
    if(Input.check(Key.LEFT)) {
      if(!isOnGround()) {
        velocity.x = velocity.x - AIR_ACCEL;
        if(velocity.x < -RUN_SPEED) {
          velocity.x = -RUN_SPEED;
        }
      }
      else if(Input.check(Key.X)) {
        if(velocity.x > -WALK_SPEED) {
          velocity.x = velocity.x - WALK_ACCEL * skidMultiplier;
        }
        else {
          velocity.x = velocity.x - RUN_ACCEL * skidMultiplier;
        }
        if(velocity.x < -RUN_SPEED) {
          velocity.x = -RUN_SPEED;
        }
      }
      else {
        velocity.x = velocity.x - WALK_ACCEL;
        if(velocity.x < -WALK_SPEED) {
          velocity.x = -WALK_SPEED;
        }
      }
      if(isOnLeftWall()) {
        velocity.x = 0;
      }
    }
    else if(Input.check(Key.RIGHT)) {
      if(!isOnGround()) {
        velocity.x = velocity.x + AIR_ACCEL;
        if(velocity.x > RUN_SPEED) {
          velocity.x = RUN_SPEED;
        }
      }
      else if(Input.check(Key.X)) {
        if(velocity.x < WALK_SPEED) {
          velocity.x = velocity.x + WALK_ACCEL * skidMultiplier;
        }
        else {
          velocity.x = velocity.x + RUN_ACCEL * skidMultiplier;
        }
        if(velocity.x > RUN_SPEED) {
          velocity.x = RUN_SPEED;
        }
      }
      else {
        velocity.x = velocity.x + WALK_ACCEL;
        if(velocity.x > WALK_SPEED) {
          velocity.x = WALK_SPEED;
        }
      }
      if(isOnRightWall()) {
        velocity.x = 0;
      }
    }
    else {
      if(velocity.x > 0) {
        velocity.x = Math.max(velocity.x - STOP_DECCEL, 0);
      }
      else {
        velocity.x = Math.min(velocity.x + STOP_DECCEL, 0);
      }
    }

    if(isOnGround()) {
      velocity.y = 0;
      if(Input.pressed(Key.Z)) {
        velocity.y = -JUMP_POWER;
      }
    }
    else {
      velocity.y += GRAVITY;
      if(Input.released(Key.Z) && velocity.y < -JUMP_CANCEL_POWER) {
        velocity.y = -JUMP_CANCEL_POWER;
      }
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
    if(!isOnGround()) {
      if(isOnWall()) {
        sprite.play("wallslide");
      }
      else {
        sprite.play("jump");
      }
    }
    else if(velocity.x != 0) {
      if(Input.check(Key.X)) {
        if(isChangingDirection()) {
          sprite.play("skid");
        }
        else {
          sprite.play("run");
        }
      }
      else {
        sprite.play("walk");
      }
    }
    else {
      sprite.play("idle");
    }
    if(velocity.x < 0) {
      sprite.flipped = true;
    }
    else if(velocity.x > 0) {
      sprite.flipped = false;
    }
  }
}
