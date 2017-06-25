package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import flash.geom.Point;

class Sword extends ActiveEntity
{

    public static inline var SLASH_COOLDOWN = 20;
    public static inline var SLASH_EXTRUDE = 10;

    private var player:Player;
    private var cooldownTimer:Int;
    private var slashType:String;
    private var inputBuffer:Bool;

    // maybe if you're carrying the player you can only shoot upwards

    public function new(player:Player)
    {
        super(Math.round(player.x), Math.round(player.y));
        this.player = player;
        player.sword = this;
        inputBuffer = false;
        cooldownTimer = 0;
        slashType = "slash";
        sprite = new Spritemap("graphics/slash.png", 144, 72);
        setHitboxTo(sprite);
        sprite.add("idle", [0]);
        sprite.add("slash", [1, 2, 3, 4, 0], 8, false);
        sprite.add("slash2", [6, 7, 8, 9, 0], 8, false);
        sprite.play("idle");
        finishInitializing();
    }

    public override function update()
    {
      super.update();
      if(cooldownTimer != 0) {
        cooldownTimer -= 1;
      }
      if(player.pressedControl("action") || inputBuffer) {
        if(cooldownTimer == 0) {
          sprite.play(slashType, true);
          sprite.flipped = player.sprite.flipped;
          if(slashType == "slash") {
            slashType = "slash2";
          }
          else {
            slashType = "slash";
          }
          cooldownTimer = SLASH_COOLDOWN;
          inputBuffer = false;
        }
        else {
          inputBuffer = true;
        }
      }
      if(sprite.flipped) {
        x = player.centerX - halfWidth - SLASH_EXTRUDE;
      }
      else {
        x = player.centerX - halfWidth + SLASH_EXTRUDE;
      }
      y = player.y - halfHeight;
    }
}
