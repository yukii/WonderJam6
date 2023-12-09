import ceramic.SeedRandom;
import clay.KeyCode;
import ceramic.KeyCode;
import ceramic.Key;
import js.html.KeyboardEvent;
import ceramic.Scene;
import ceramic.Quad;
import ceramic.Color;
import ceramic.VisualTransition;
import ceramic.TouchInfo;

class GetStarted extends Scene {
    
    var quad:Quad;
    var play:Player;
	var quad1:Quad;



    override function create() {
        quad = new Quad();
        quad.size(100, 100);
        quad.color = Color.YELLOW;
        quad.pos(width*0.5, height*0.5);
        quad.anchor(0.5,0.5);
        add(quad);

        quad.onPointerDown(this, info -> {
            log.debug('point down: $info');
            quad.color = Color.random();
        });
        
        /*play = new Player();
        quad.component('play', play);
        input.onKeyDown(this, keyDown);
        input.onKeyUp(this, keyUp);*/
    }
}