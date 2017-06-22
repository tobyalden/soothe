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

    public var bobTimer:Float;
    private var player:Player;
    private var destination:Point;
    private var permissableDistance:Float = HOVER_HEIGHT;


    public function new(player:Player)
    {
        super(Math.round(player.x), Math.round(player.y));
        this.player = player;
        player.option = this;
        permissableDistance = HOVER_HEIGHT;
        destination = new Point(player.x, player.y);
        sprite = new Spritemap("graphics/option.png", 18, 18);
        setHitbox(18, 18);
        sprite.add("idle", [0, 1, 2, 3], 2);
        sprite.add("carrying", [0, 3], 4);
        bobTimer = 0;
        name = "option";
        finishInitializing();
    }

    public override function update()
    {
      bobTimer += BOB_SPEED;
      if(player.isHangingOnOption) {
        destination.y = player.y - HOVER_HEIGHT + 5;
        sprite.play("carrying");
      }
      else {
        destination.y = player.y - HOVER_HEIGHT;
        sprite.play("idle");
      }
      if(player.isHangingOnOption && player.sprite.flipped) {
        destination.x = player.centerX;
      }
      else if(player.isHangingOnOption) {
        destination.x = player.centerX - width;
      }
      else if(player.sprite.flipped) {
        destination.x = player.centerX - halfWidth + HOVER_HEIGHT;
      }
      else {
        destination.x = player.centerX - halfWidth - HOVER_HEIGHT;
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
      if(Math.abs(x - player.x) > Math.abs(destination.x - player.x) + 0.1) {
        x = destination.x;
      }
      if(player.isHangingOnOption) {
        y = destination.y + Math.sin(bobTimer * 2) * BOB_HEIGHT*1.2;
      }
      else {
        y = destination.y + Math.sin(bobTimer) * BOB_HEIGHT;
      }
    }
}
