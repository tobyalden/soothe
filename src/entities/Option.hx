package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import flash.geom.Point;

class Option extends ActiveEntity
{

    public static inline var ACCEL = 2;
    public static inline var MAX_SPEED = 2;
    public static inline var HOVER_HEIGHT = 20;
    public static inline var BOB_SPEED = 0.1;
    public static inline var BOB_HEIGHT = 2;

    private var player:Player;
    private var bobTimer:Float;
    private var destination:Point;

    public function new(player:Player)
    {
        super(Math.round(player.x), Math.round(player.y));
        this.player = player;
        destination = new Point(player.x, player.y);
        sprite = new Spritemap("graphics/option.png", 18, 18);
        sprite.add("idle", [0]);
        bobTimer = 0;
        finishInitializing();
    }

    public override function update()
    {
      bobTimer += BOB_SPEED;
      destination.y = player.y - HOVER_HEIGHT;
      /*destination.y = player.y - HOVER_HEIGHT + Math.sin(bobTimer) * BOB_HEIGHT;*/
      if(player.sprite.flipped) {
        destination.x = player.x + HOVER_HEIGHT;
      }
      else {
        destination.x = player.x - HOVER_HEIGHT;
      }
      moveTowardsDestination();
    }

    private function moveTowardsDestination() {
      if(Math.abs(x - destination.x) < Math.abs(velocity.x) + ACCEL) {
        velocity.x = 0;
        x = destination.x;
      }
      else if(x < destination.x) {
        velocity.x += ACCEL;
      }
      else {
        velocity.x -= ACCEL;
      }
      if(Math.abs(y - destination.y) < Math.abs(velocity.y) + ACCEL) {
        velocity.y = 0;
        y = destination.y;
      }
      else if(y < destination.y) {
        velocity.y += ACCEL;
      }
      else {
        velocity.y -= ACCEL;
      }
      velocity.x = Math.min(velocity.x, MAX_SPEED);
      velocity.x = Math.max(velocity.x, -MAX_SPEED);
      velocity.y = Math.min(velocity.y, MAX_SPEED);
      velocity.y = Math.max(velocity.y, -MAX_SPEED);
      moveBy(velocity.x, velocity.y);
    }
}
