package entities;

import com.haxepunk.utils.*;
import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.HXP;
import scenes.*;

class Player extends ActiveEntity
{

    public static inline var WALK_SPEED = 2.5;
    public static inline var WALK_ACCEL = 0.25;
    public static inline var WALK_TURN_MULTIPLIER = 2;
    public static inline var RUN_TO_WALK_DECCEL = 0.38;
    public static inline var RUN_SPEED = 4.6;
    public static inline var RUN_ACCEL = 0.15;
    public static inline var AIR_ACCEL = 0.18;
    public static inline var AIR_DECCEL = 0.1;
    public static inline var STOP_DECCEL = 0.3;

    public static inline var JUMP_POWER = 6;
    public static inline var JUMP_CANCEL_POWER = 2;
    public static inline var WALL_JUMP_POWER = 4.65;
    public static inline var LEDGE_HOP_POWER = 4.10;
    public static inline var HOP_TIMER = 60;

    public static inline var WALL_STICK_TIME = 10;
    public static inline var GRAVITY = 0.25;
    public static inline var WALL_GRAVITY = 0.1;
    public static inline var MAX_FALL_SPEED = 10;
    public static inline var MAX_WALL_FALL_SPEED = 5;
    public static inline var SKID_THRESHOLD = 2.8;
    public static inline var HEAD_BONK_SPEED = 0.5;

    public static inline var JOYSTICK_RUN_THRESHOLD = 0.5;

    public static inline var CAMERA_SCALE_THRESHOLD = 500;

    public static inline var INVINCIBILITY_DURATION = 50;

    public static inline var HIT_VELOCITY_X = 4;
    public static inline var HIT_VELOCITY_Y = 2;

    public var CONTROLS = [
        "left"=>Key.LEFT,
        "right"=>Key.RIGHT,
        "up"=>Key.UP,
        "down"=>Key.DOWN,
        "jump"=>Key.Z,
        "action"=>Key.X,
    ];

    public var option:Option;
    public var sword:Sword;
    public var isHangingOnOption:Bool;
    public var isInteracting:Bool;

    private var isRunning:Bool;
    private var isSkidding:Bool;
    private var wallStickTimer:Int;
    private var hopTimer:Int;
    private var controls:Map<String, Int>;

    private var isUsingJoystick:Bool;
    private var joystick:Joystick;

        public function new(x:Int, y:Int)
        {
                super(x, y);
        this.sprite = new Spritemap("graphics/player.png", 16, 24);
        this.damageFlash = new Timer(INVINCIBILITY_DURATION);
        this.isHangingOnOption = false;
        this.isInteracting = false;
        this.isRunning = false;
        this.isSkidding = false;
        this.wallStickTimer = 0;
        this.hopTimer = 0;
        this.controls = CONTROLS;
        this.isUsingJoystick = false;
        this.joystick = Input.joystick(0);
        type = "player";
        name = "player";
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

    public override function moveCollideX(e:Entity) {
        velocity.x /= 2;
        return true;
    }

    public override function update()
    {
        isUsingJoystick = Input.joysticks > 0;
        if(isFlashing && !damageFlash.isActive()) {
            stopFlashing();
        }
        if(isHangingOnOption) {
            hangMovement();
        }
        else {
            movement();
        }

        if(checkControl("reset")) {
            y = 300;
            x = 10;
        }

        animate();

        if(name == "player") {
            setCamera();
        }

        var damager = collideTypes(["enemy", "missile"], x, y);
        if(damager != null) {
            if(!damageFlash.isActive()) {
                takeDamageFromEntity(damager);
            }
            if(damager.type == "missile") {
                scene.remove(damager);
            }
        }
        super.update();
    }

    public function movement() {
        isInteracting = pressedControl("down");
        isRunning = (
            !isUsingJoystick
            || Math.abs(joystick.getAxis(0)) > JOYSTICK_RUN_THRESHOLD
            || Input.joystick(0).hat.x != 0 || Input.joystick(0).hat.y != 0
        );
        if(isStartingSkid()) {
            isSkidding = true;
        }
        if(isStoppingSkid()) {
            isSkidding = false;
        }
        if(hopTimer > 0) {
            hopTimer -= 1;
        }

        if(checkControl("left")) {
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
            else if(isRunning) {
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
        else if(checkControl("right")) {
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
            else if(isRunning) {
                if(velocity.x < WALK_SPEED) {
                    velocity.x += WALK_ACCEL;
                }
                else {
                    velocity.x += RUN_ACCEL;
                }
            }
            else {
                velocity.x = velocity.x + WALK_ACCEL;
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

        if(isRunning) {
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
            velocity.y = Math.min(velocity.y, 0);
            if(pressedControl("jump")) {
                    velocity.y = -JUMP_POWER;
            }
        }
        else if(isOnWall()) {
            if(velocity.y > 0) {
                velocity.y += WALL_GRAVITY;
            }
            else {
                velocity.y += GRAVITY;
            }
            if(pressedControl("jump")) {
                var tryingToJump = (
                    (checkControl("up") || pressedControl("jump")) && hopTimer == 0
                );
                if(
                    tryingToJump
                    && isOnLeftWall()
                    && HXP.scene.collidePoint("walls", x - 1, y - height/4) == null
                    && !checkControl("right")
                ) {
                    velocity.y = -LEDGE_HOP_POWER;
                    hopTimer = HOP_TIMER;
                }
                else if(
                    tryingToJump
                    && isOnRightWall()
                    && HXP.scene.collidePoint("walls", right + 1, y - height/4) == null
                    && !checkControl("left")
                ) {
                    hopTimer = HOP_TIMER;
                    velocity.y = -LEDGE_HOP_POWER;
                }
                else if(isOnLeftWall()) {
                    velocity.y = -WALL_JUMP_POWER;
                    velocity.x = RUN_SPEED;
                }
                else if(isOnRightWall()) {
                    velocity.y = -WALL_JUMP_POWER;
                    velocity.x = -RUN_SPEED;
                }
            }

        }
        else {
            if(isOnCeiling()) {
                velocity.y = HEAD_BONK_SPEED;
            }
            velocity.y += GRAVITY;
            if(releasedControl("jump")) {
            }
        }

        if(!isOnGround()) {
            if(releasedControl("jump") && velocity.y < -JUMP_CANCEL_POWER) {
                velocity.y = -JUMP_CANCEL_POWER;
            }
            if(pressedControl("jump") && !isOnWall()) {
                isHangingOnOption = true;
                option.bobTimer = 1;
            }
        }

        if(isOnWall()) {
            velocity.y = Math.min(velocity.y, MAX_WALL_FALL_SPEED);
        }
        else {
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }

        if(
            !(isOnRightWall() && checkControl("left")) &&
            !(isOnLeftWall() && checkControl("right"))
        ) {
            wallStickTimer = 0;
        }

        moveBy(velocity.x, 0, "walls");
        moveBy(0, velocity.y, "walls");
    }

    public function hangMovement() {
        isInteracting = false;
        if(releasedControl("jump")) {
            isHangingOnOption = false;
        }
        if(checkControl("left")) {
            velocity.x -= AIR_ACCEL;
        }
        else if(checkControl("right")) {
            velocity.x += AIR_ACCEL;
        }
        else {
            if(velocity.x > 0) {
                velocity.x = Math.max(velocity.x - AIR_DECCEL, 0);
            }
            else {
                velocity.x = Math.min(velocity.x + AIR_DECCEL, 0);
            }
        }
        velocity.x = Math.min(velocity.x, RUN_SPEED);
        velocity.x = Math.max(velocity.x, -RUN_SPEED);
        velocity.y = Math.max(velocity.y - GRAVITY * 1.03, -RUN_SPEED/2);
        moveBy(velocity.x, 0, "walls");
        moveBy(
            0, velocity.y + Math.sin(option.bobTimer * 2) * Option.BOB_HEIGHT/1.5,
            "walls"
        );
    }

    private function isChangingDirection() {
        return (
            checkControl("left") && velocity.x > 0 ||
            checkControl("right") && velocity.x < 0
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

    public function takeDamageFromEntity(damager:Entity) {
        damageFlash.restart();
        startFlashing();
        if(x < damager.x)
        {
            velocity.x += -HIT_VELOCITY_X;
        }
        else
        {
            velocity.x += HIT_VELOCITY_X;
        }
        if(isOnGround()) {
            velocity.y = -HIT_VELOCITY_Y;
        }
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
            if(isRunning) {
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

    private function setCamera() {
        HXP.camera.x = x - HXP.halfWidth;
        HXP.camera.y = y - HXP.halfHeight;
    }


    public function checkControl(control:String) {
        if(isUsingJoystick) {
            if(control == "left") {
                return joystick.getAxis(0) < 0 || Input.joystick(0).hat.x == -1;
            }
            if(control == "right") {
                return joystick.getAxis(0) >    0 || Input.joystick(0).hat.x == 1;
            }
            if(control == "up") {
                return joystick.getAxis(1) < 0 || Input.joystick(0).hat.y == -1;
            }
            if(control == "down") {
                return joystick.getAxis(1) > 0 || Input.joystick(0).hat.y == 1;
            }
            if(control == "jump") {
                return joystick.check(1);
            }
            if(control == "action") {
                return joystick.check(0);
            }
        }
        if(Input.check(controls[control])) {
            return true;
        }
        return false;
    }

    public function pressedControl(control:String) {
        /*for (i in 0...100) {
            if(joystick.pressed(i)) {
                trace(i + "pressed!");
            }
        }*/
        if(isUsingJoystick) {
            if(control == "jump") {
                return joystick.pressed(4) ||  joystick.pressed(1);
            }
            if(control == "action") {
                return joystick.pressed(0);
            }

        }
        else {
            if(Input.pressed(controls[control])) {
                return true;
            }
        }
        return false;
    }

    public function releasedControl(control:String) {
        if(isUsingJoystick) {
            if(control == "jump") {
                return joystick.released(4) || joystick.released(1);
            }
            if(control == "action") {
                return joystick.released(0);
            }
        }
        else {
            if(Input.released(controls[control])) {
                return true;
            }
        }
        return false;
    }
}
