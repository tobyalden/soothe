package entities;

import flash.system.System;
import com.haxepunk.utils.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.HXP;

class Player extends ActiveEntity
{

  public static inline var WALK_SPEED = 2.5;
  public static inline var WALK_ACCEL = 0.25;
  public static inline var WALK_TURN_MULTIPLIER = 2;
  public static inline var RUN_TO_WALK_DECCEL = 0.38;
  public static inline var RUN_SPEED = 4.6;
  public static inline var RUN_ACCEL = 0.08;
  public static inline var AIR_ACCEL = 0.18;
  public static inline var AIR_DECCEL = 0.1;
  public static inline var STOP_DECCEL = 0.3;
  public static inline var JUMP_POWER = 6;
  public static inline var SKID_JUMP_POWER = 7;
  public static inline var WALL_JUMP_POWER = 4.65;
  public static inline var LEDGE_HOP_POWER = 4.10;
  public static inline var WALL_STICK_TIME = 10;
  public static inline var JUMP_CANCEL_POWER = 2;
  public static inline var GRAVITY = 0.25;
  public static inline var WALL_GRAVITY = 0.20;
  public static inline var MAX_FALL_SPEED = 10;
  public static inline var MAX_WALL_FALL_SPEED = 6;
  public static inline var SKID_THRESHOLD = 2.8;
  public static inline var HEAD_BONK_SPEED = 0.5;

  private var isSkidding:Bool;
  private var isHanging:Bool;
  private var wallStickTimer:Int;

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
    isSkidding = false;
    isHanging = false;
    wallStickTimer = 0;
		finishInitializing();
	}

  private function isChangingDirection() {
    return (
      Input.check(Key.LEFT) && velocity.x > 0 ||
      Input.check(Key.RIGHT) && velocity.x < 0
    );
  }

  private function isStartingSkid() {
    return (
      isOnGround() &&
      isChangingDirection() &&
      Math.abs(velocity.x) > SKID_THRESHOLD
    );
  }

  private function isStoppingSkid() {
    return velocity.x == 0 || !isChangingDirection();
  }

  public override function update()
  {
    if(isStartingSkid()) {
      isSkidding = true;
    }
    if(isStoppingSkid()) {
      isSkidding = false;
    }
    if(Input.check(Key.LEFT)) {
      if(!isOnGround()) {
        if(isOnRightWall()) {
          wallStickTimer += 1;
          if(wallStickTimer > WALL_STICK_TIME) {
            velocity.x -= WALK_ACCEL;
          }
        }
        else {
          velocity.x -= AIR_ACCEL;
        }
      }
      else if(Input.check(Key.X)) {
        if(velocity.x > -WALK_SPEED) {
          velocity.x -= WALK_ACCEL;
        }
        else {
          velocity.x -= RUN_ACCEL;
        }
      }
      else {
        var turnMultiplier = 1.0;
        if(isChangingDirection()) {
          turnMultiplier = WALK_TURN_MULTIPLIER;
        }
        velocity.x = velocity.x - WALK_ACCEL * turnMultiplier;
      }
      if(isOnLeftWall()) {
        velocity.x = 0;
      }
    }
    else if(Input.check(Key.RIGHT)) {
      if(!isOnGround()) {
        if(isOnLeftWall()) {
          wallStickTimer += 1;
          if(wallStickTimer > WALL_STICK_TIME) {
            velocity.x += WALK_ACCEL;
          }
        }
        else {
          velocity.x += AIR_ACCEL;
        }
      }
      else if(Input.check(Key.X)) {
        if(velocity.x < WALK_SPEED) {
          velocity.x += WALK_ACCEL;
        }
        else {
          velocity.x += RUN_ACCEL;
        }
      }
      else {
        var turnMultiplier = 1.0;
        if(isChangingDirection()) {
          turnMultiplier = WALK_TURN_MULTIPLIER;
        }
        velocity.x = velocity.x + WALK_ACCEL * turnMultiplier;
      }
      if(isOnRightWall()) {
        velocity.x = 0;
      }
    }
    else {
      var deccel = STOP_DECCEL;
      if(!isOnGround()) {
        deccel = AIR_DECCEL;
      }
      if(velocity.x > 0) {
        velocity.x = Math.max(velocity.x - deccel, 0);
      }
      else {
        velocity.x = Math.min(velocity.x + deccel, 0);
      }
    }

    if(Input.check(Key.X)) {
      if(velocity.x > RUN_SPEED) {
        velocity.x = RUN_SPEED;
      }
      else if(velocity.x < -RUN_SPEED) {
        velocity.x = -RUN_SPEED;
      }
    }
    else {
      if(velocity.x > WALK_SPEED) {
        velocity.x = Math.max(velocity.x - RUN_TO_WALK_DECCEL, WALK_SPEED);
      }
      else if(velocity.x < -WALK_SPEED) {
        velocity.x = Math.min(velocity.x + RUN_TO_WALK_DECCEL, -WALK_SPEED);
      }
    }

    if(isOnGround()) {
      velocity.y = 0;
      if(Input.pressed(Key.Z)) {
        if(isSkidding) {
          velocity.y = -SKID_JUMP_POWER;
          velocity.x = WALK_SPEED * -(velocity.x / Math.abs(velocity.x));
        }
        else {
          velocity.y = -JUMP_POWER;
        }
      }
    }
    else if(isOnWall()) {
      if(velocity.y > 0) {
        velocity.y += WALL_GRAVITY;
      }
      else {
        velocity.y += GRAVITY;
      }
      if(isHanging) {
        velocity.y = 0;
      }
      if(Input.pressed(Key.Z)) {
        velocity.y = -WALL_JUMP_POWER;
        if(isOnLeftWall()) {
          if(HXP.scene.collidePoint("walls", x - 1, y - height/2) != null || !Input.check(Key.LEFT)) {
            velocity.x = RUN_SPEED;
          }
          else {
            velocity.y = -LEDGE_HOP_POWER;
          }
        }
        else if(isOnRightWall()) {
          if(HXP.scene.collidePoint("walls", right + 1, y - height/2) != null || !Input.check(Key.RIGHT)) {
            velocity.x = -RUN_SPEED;
          }
          else {
            velocity.y = -LEDGE_HOP_POWER;
          }
        }
      }
    }
    else {
      if(isOnCeiling()) {
        velocity.y = HEAD_BONK_SPEED;
      }
      velocity.y += GRAVITY;
    }

    if(!isOnGround()) {
      if(Input.released(Key.Z) && velocity.y < -JUMP_CANCEL_POWER) {
        velocity.y = -JUMP_CANCEL_POWER;
      }
    }

    if(isOnWall()) {
      velocity.y = Math.min(velocity.y, MAX_WALL_FALL_SPEED);
    }
    else {
      velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
    }

    if(
      !(isOnRightWall() && Input.check(Key.LEFT)) &&
      !(isOnLeftWall() && Input.check(Key.RIGHT))
    ) {
      wallStickTimer = 0;
    }

    moveBy(velocity.x, 0, "walls");
    moveBy(0, velocity.y, "walls");

    if(Input.check(Key.ESCAPE)) {
      System.exit(0);
    }

    animate();

    super.update();
  }

  public override function moveCollideX(e:Entity) {
    velocity.x /= 2;
    return true;
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
        if(isSkidding) {
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
