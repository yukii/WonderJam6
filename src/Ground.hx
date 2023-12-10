import ceramic.Assets;
import ceramic.Sprite;

using ceramic.SpritePlugin;

class Ground extends Sprite {

    public function new(assets:Assets) {
        super();

        sheet = assets.sheet(Sprites.BOMBERLIKE_BLOCKS);

        autoComputeSize = false;
        size(TILE_SIZE, TILE_SIZE);
        frameOffset(-(SHEET_FRAME_SIZE - TILE_SIZE) / 2, -(SHEET_FRAME_SIZE - TILE_SIZE) / 2);

        animation = 'GROUND';
        quad.roundTranslation = 1;
    }

}
