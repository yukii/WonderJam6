package;

import ceramic.ImageAsset;
import ceramic.SpriteSheetAnimation;
import arcade.Body;
import ceramic.Assets;
import ceramic.InputMap;
import ceramic.Sprite;
import ceramic.SpriteSheet;
import ceramic.StateMachine;
import ceramic.Timer;
import ceramic.AsepriteParser;

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
    
    var playSpeed:Float = 50;
    
    var tileWidth:Int = 16;

    var tileHeight:Int = 16;

    var imgAse:ImageAsset;

    @event function bombExplode(posX:Int, posY:Int);
    
    @component var machine = new StateMachine<PlayerState>();
    var inputMap = new InputMap<PlayerInput>();

    public var dotBodyBottom(default, null) = new Body(0, 0, 2, 2);

    public function new(assets:Assets, map:Array<Int>) {
        super();

        autoComputeSize = false;

        initArcadePhysics();
        body.collideWorldBounds = true;

        sheet = new SpriteSheet();
        sheet.texture = assets.texture(Images.CHARACTERS);
        sheet.grid(24,24);
        // sheet.addGridAnimation('idle', [0], 0);
        sheet.addGridAnimation('idle', [0], 0);
        anchor(0.5,1);
        
        // animation = 'idle';
        quad.roundTranslation = 1;
        scaleX = -1;
        size(tileWidth,tileHeight);
        frameOffset(-3,-2);

        bindInput();
    }

    override function update(delta:Float) {
        super.update(delta);
        
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
        var canMoveLeftRight = (!inputMap.justPressed(DOWN) && !inputMap.justPressed(UP));

        if(inputMap.pressed(RIGHT) && canMoveLeftRight) {
            velocityX = playSpeed;
            if (machine.state == DEFAULT) {
                // animation
                animation = 'idle';
            }
            scaleX = -1;
        }
        else if(inputMap.pressed(LEFT) && canMoveLeftRight) {
            velocityX = -playSpeed;
            if (machine.state == DEFAULT) {
                // animation
                animation = 'idle';
            }
            scaleX = 1;
        }
        else {
            animation = 'idle';
            velocityX = 0;
        }

        if(inputMap.pressed(UP)) {
            velocityY = -playSpeed;
            if (machine.state == DEFAULT) {
                // animation
                animation = 'idle';
            }
            scaleX = 1;
        }
        else if(inputMap.pressed(DOWN)) {
            velocityY = playSpeed;
            if (machine.state == DEFAULT) {
                // animation
                animation = 'idle';
            }
            scaleX = -1;
        }
        else {
            animation = 'idle';
            velocityY = 0;
        }
    }

    function dropBomb(delta:Float) {
        if(inputMap.pressed(BOMB)) {
            // to do
            Timer.delay(this, 3, () -> emitBombExplode(Math.floor(x), Math.floor(y)));
        }
    }
}