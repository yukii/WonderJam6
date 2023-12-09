package;

import ceramic.Key;
import clay.KeyCode;
import ceramic.Asset;
import arcade.Body;
import arcade.Direction;
import ceramic.ArcadeWorld;
import ceramic.Assets;
import ceramic.Group;
import ceramic.InputMap;
import ceramic.Sprite;
import ceramic.SpriteSheet;
import ceramic.StateMachine;
import ceramic.Tilemap;
import ceramic.VisualArcadePhysics;

enum abstract PlayerState(Int) {

    /**
     * Player's default state: walking or not moving at all
     */
    var DEFAULT;

    /**
     * Player is jumping
     */
    var JUMP;

}

/**
 * The input keys that will make player interaction
 */
 enum abstract PlayerInput(Int) {

    var RIGHT;

    var LEFT;

    var DOWN;

    var UP;

    var JUMP;

}

class Player extends Sprite {
    
    var playSpeed:Float = 50;
    
    var tileWidth:Int = 18;

    var tileHeight:Int = 18;
    
    @component var machine = new StateMachine<PlayerState>();
    var inputMap = new InputMap<PlayerInput>();

    public var dotBodyBottom(default, null) = new Body(0, 0, 2, 2);

    public function new(assets:Assets) {
        super();

        autoComputeSize = false;

        initArcadePhysics();
        body.collideWorldBounds = true;

        sheet = new SpriteSheet();
        sheet.texture = assets.texture(Images.CHARACTERS);
        sheet.grid(24,24);
        sheet.addGridAnimation('idle', [0], 0);
        anchor(0.5,1);
        
        animation = 'idle';
        quad.roundTranslation = 1;
        scaleX = -1;
        size(18,22);
        frameOffset(-3,-2);

        bindInput();
    }

    override function update(delta:Float) {
        super.update(delta);
        
        testMove(delta);
    }

    function bindInput() {

        // Bind keyboard
        //
        inputMap.bindKeyCode(RIGHT, RIGHT);
        inputMap.bindKeyCode(LEFT, LEFT);
        inputMap.bindKeyCode(DOWN, DOWN);
        inputMap.bindKeyCode(UP, UP);
        inputMap.bindKeyCode(JUMP, SPACE);
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
        inputMap.bindGamepadButton(JUMP, A);

    }

    function testMove(delta:Float) {
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
}