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
      if(Math.abs(x - destination.x) < Math.abs(velocity.x) + ACCEL) {
        velocity.x /= 2;
        x = destination.x;
      }
      else if(destination.x > x) {
        velocity.x += ACCEL;
      }
      else {
        velocity.x -= ACCEL;
      }
      velocity.x = Math.min(velocity.x, MAX_SPEED);
      velocity.x = Math.max(velocity.x, -MAX_SPEED);

      x += velocity.x;
      if(Math.abs(x - player.x) > HOVER_HEIGHT) {
        if(x > player.x) {
          x = player.x + HOVER_HEIGHT;
        }
        else {
          x = player.x - HOVER_HEIGHT;
        }
      }
      y = destination.y + Math.sin(bobTimer) * BOB_HEIGHT;
    }
}
