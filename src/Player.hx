package;

import arcade.Body;
import ceramic.AsepriteParser;
import ceramic.Assets;
import ceramic.ImageAsset;
import ceramic.InputMap;
import ceramic.Sprite;
import ceramic.SpriteSheet;
import ceramic.SpriteSheetAnimation;
import ceramic.StateMachine;
import ceramic.Timer;
import ceramic.macros.EnumAbstractMacro;

using ceramic.SpritePlugin;

enum abstract PlayerDirection(Int) {

    var UP;

    var RIGHT;

    var DOWN;

    var LEFT;

    public function toString() {
        // A macro to get a string from the enum abstract
        return EnumAbstractMacro.toStringSwitch(PlayerDirection, abstract);
    }

}

enum abstract PlayerState(Int) {

    /**
     * Player's default state: walking or not moving at all
     */
    var DEFAULT;

    /**
     * Player is BOMBing
     */
    var BOMB;

}

/**
 * The input keys that will make player interaction
 */
 enum abstract PlayerInput(Int) {

    var RIGHT;

    var LEFT;

    var DOWN;

    var UP;

    var BOMB;

}

class Player extends Sprite {

    var playSpeed:Float = 80;

    var direction:PlayerDirection = RIGHT;

    public var _levelData:LevelData;

    var index:Int;

    var gridX:Int;

    var gridY:Int;

    @event function bombExplode(posX:Int, posY:Int);
    @event function bombDisplay(posX:Int, posY:Int);

    @component var machine = new StateMachine<PlayerState>();
    var inputMap = new InputMap<PlayerInput>();

    public var dotBodyBottom(default, null) = new Body(0, 0, 2, 2);

    public function new(assets:Assets, levelData:LevelData) {
        super();

        _levelData = levelData;

        autoComputeSize = false;

        initArcadePhysics();
        body.collideWorldBounds = true;

        sheet = assets.sheet(Sprites.BOMBERLIKE_CHARACTER);

        animation = 'IDLE_' + direction.toString();
        quad.roundTranslation = 1;
        size(TILE_SIZE - 6, TILE_SIZE - 9);
        frameOffset(-(16 + 3), -(16 + 4));

        bindInput();

        machine.state = DEFAULT;
    }

    public function updatePlayer(delta:Float) {

        gridX = Math.floor(x/TILE_SIZE);
        gridY = Math.floor(y/TILE_SIZE);
        index = gridY * _levelData.columns + gridX;
        move(delta);
        dropBomb(delta);
    }

    function bindInput() {

        // Bind keyboard
        //
        inputMap.bindKeyCode(RIGHT, RIGHT);
        inputMap.bindKeyCode(LEFT, LEFT);
        inputMap.bindKeyCode(DOWN, DOWN);
        inputMap.bindKeyCode(UP, UP);
        inputMap.bindKeyCode(BOMB, SPACE);
        // We use scan code for these so that it
        // will work with non-qwerty layouts as well
        inputMap.bindScanCode(RIGHT, KEY_D);
        inputMap.bindScanCode(LEFT, KEY_A);
        inputMap.bindScanCode(DOWN, KEY_S);
        inputMap.bindScanCode(UP, KEY_W);

        // Bind gamepad
        //
        inputMap.bindGamepadAxisToButton(RIGHT, LEFT_X, 0.25);
        inputMap.bindGamepadAxisToButton(LEFT, LEFT_X, -0.25);
        inputMap.bindGamepadAxisToButton(DOWN, LEFT_Y, 0.25);
        inputMap.bindGamepadAxisToButton(UP, LEFT_Y, -0.25);
        inputMap.bindGamepadButton(RIGHT, DPAD_RIGHT);
        inputMap.bindGamepadButton(LEFT, DPAD_LEFT);
        inputMap.bindGamepadButton(DOWN, DPAD_DOWN);
        inputMap.bindGamepadButton(UP, DPAD_UP);
        inputMap.bindGamepadButton(BOMB, A);

    }

    function move(delta:Float) {
        var blockedDown = body.blockedDown;

        var canMoveUp = true;
        var canMoveDown = true;
        var canMoveLeft = true;
        var canMoveRight = true;

        if(inputMap.pressed(RIGHT)) {
            direction = RIGHT;
            if (canMoveRight) {
                velocityX = playSpeed;
            }
            if (machine.state == DEFAULT) {
                // animation
                animation = 'WALK_' + direction.toString();
            }
        }
        else if(inputMap.pressed(LEFT)) {
            direction = LEFT;
            if (canMoveLeft) {
                velocityX = -playSpeed;
            }
            if (machine.state == DEFAULT) {
                // animation
                animation = 'WALK_' + direction.toString();
            }
        }
        else {
            velocityX = 0;
        }

        if(inputMap.pressed(UP)) {
            direction = UP;
            if (canMoveUp) {
                velocityY = -playSpeed;
            }
            if (machine.state == DEFAULT) {
                // animation
                animation = 'WALK_' + direction.toString();
            }
        }
        else if(inputMap.pressed(DOWN)) {
            direction = DOWN;
            if (canMoveDown) {
                velocityY = playSpeed;
            }
            if (machine.state == DEFAULT) {
                // animation
                animation = 'WALK_' + direction.toString();
            }
        }
        else {
            velocityY = 0;
        }

        if (!inputMap.pressed(UP) && !inputMap.pressed(RIGHT) && !inputMap.pressed(DOWN) && !inputMap.pressed(LEFT)) {
            animation = 'IDLE_' + direction.toString();
        }

        depth = DEPTH_WALL + index + 0.15;
    }

    function dropBomb(delta:Float) {
        if(inputMap.pressed(BOMB)) {
            // trace('posX' + x + ', posy : ' + y);
            var posX = Math.floor(x);
            var posY = Math.floor(y);

            emitBombDisplay(posX, posY);
            Timer.delay(this, 3, () -> emitBombExplode(posX, posY));
        }
    }
}