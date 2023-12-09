package;

import ceramic.Group;
import ceramic.Scene;
import ceramic.Tilemap;

using ceramic.TilemapPlugin;

class GameScene extends Scene {
    
    var tilemap:Tilemap;
    var player:Player;
    var collid:Group<Collider>;

    var ldtkName = Tilemaps.WORLD_MAP_GRID_VANIA_LAYOUT;

    override function preload() {
        // assets.add(Images.TILES);
        assets.add(Images.CHARACTERS);
        // assets.add(Tilemap.TILEMAP);
        assets.add(ldtkName);
    }

    override function create() {
        // assets.texture(Images.TILES).filter = NEAREST;
        assets.texture(Images.CHARACTERS).filter = NEAREST;

        initMap();
        initPlayer();
    }

    function initMap() {
        /*tilemap = new Tilemap();
        tilemap.roundTilesTranslation = 1;
        // tilemap.tilemapData = assets.tilemap(Tilemaps.TILEMAP);
        tilemap.depth = 1;
        add(tilemap);*/
        tilemap = null;
        var ldktData = assets.ldtk(ldtkName);
        var level = ldktData.worlds[0].levels[0];

        level.ensureLoaded(() -> {
            tilemap = new Tilemap();
            tilemap.depth = 1;
            tilemap.tilemapData = level.ceramicTilemap;
            add(tilemap);

            level.createVisualsForEntities(tilemap);
            
            trace(level.layerInstances[0].entityInstances[0].def.identifier);
        });
    }

    function initPlayer() {
        player = new Player(assets);
        player.depth = 10;

        player.pos(0,0);
        add(player);
    }

    function initCollider() {
        collid = new Group('boxes');
        /*for (tmxbox in findTmxObjects('box', 'objects')) {
            var col = new Collider(assets);
            col.pos(tmxbox.x, tmxbox.y);
            col.depth = 2;
            tilemap.add(col);
            collid.add(col);
        }*/
    }

    
    /**
     * A helper to find a list of objects from TMX data
     * @param name The name of the objects we are looking for
     * @param layer (optional) The name of the layer containing the object in TMX data
     */
     /*function findTmxObjects(name:String, ?layer:String) {

        var result = [];

        for (layerData in tmxMap.layers) {
            switch layerData {
                default:
                case LObjectGroup(group):
                    if (layer == null || group.name == layer) {
                        for (obj in group.objects) {
                            if (obj.name == name) {
                                result.push(obj);
                            }
                        }
                    }
            }
        }

        return result;

    }*/
}