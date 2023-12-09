package;

import stb.Image;
import ceramic.Assets;
import ceramic.Sprite;
import ceramic.SpriteSheet;
import ceramic.Visual;

class Collider extends Sprite {
    static var _sheet:SpriteSheet = null;

    var triggered:Bool = false;

    public function new(assets:Assets) {
        super();

        initArcadePhysics();

        if(_sheet == null) {
            _sheet = new SpriteSheet();
            _sheet.texture = assets.texture(Images.ATLAS__SUNNY_LAND);
            _sheet.grid(10, 10);
        }

        sheet = _sheet;

        size(18,18);

        onCollide(this, handleCollide);
    }

    function handleCollide(visual1:Visual, visual2:Visual) {
        if(triggered) {
            return;
        }

        var subject = visual1 == this ? visual2 : visual1;
        if (subject is Player) {
            triggered = true;
            trace("triggered by Player");
        }
    }
}