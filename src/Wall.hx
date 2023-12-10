import ceramic.Assets;
import ceramic.Sprite;

using ceramic.SpritePlugin;

class Wall extends Sprite {

    var _tileKind:TileKind;

    public function new(assets:Assets, tileKind:TileKind) {
        super();

        initArcadePhysics();
        immovable = true;

        _tileKind = tileKind;

        sheet = assets.sheet(Sprites.BOMBERLIKE_BLOCKS);

        autoComputeSize = false;
        size(TILE_SIZE, TILE_SIZE);
        frameOffset(-(SHEET_FRAME_SIZE - TILE_SIZE) / 2, -(SHEET_FRAME_SIZE - TILE_SIZE) / 2);

        animation = switch tileKind {
            case BLUE:
                'WALL_BLUE';
            case GREEN:
                'WALL_GREEN';
            case RED:
                'WALL_RED';
            case YELLOW:
                'WALL_YELLOW';
            case _:
                null;
        }

        quad.roundTranslation = 1;
    }

}
