import ceramic.Sprite;
import ceramic.Assets;
import ceramic.Sprite;

using ceramic.SpritePlugin;

class Bomb extends Sprite {

    public function new(assets:Assets) {
        super();

        sheet = assets.sheet(Sprites.BOMBERLIKE_EXPLOSION);
        
        autoComputeSize = false;
        size(TILE_SIZE, TILE_SIZE);
        frameOffset(-(SHEET_FRAME_SIZE - TILE_SIZE) / 2, -(SHEET_FRAME_SIZE - TILE_SIZE) / 2);

        animation = 'EXPLOSION_RED_IN';
        quad.roundTranslation = 1;
    }
}