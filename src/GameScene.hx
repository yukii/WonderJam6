package;

import ceramic.Color;
import ceramic.Quad;
import ceramic.Group;
import ceramic.Scene;
import ceramic.Tilemap;

using ceramic.TilemapPlugin;


enum abstract TileKind(Int) from Int to Int {
    var GROUND = 0;
    var VOID = 9;
    var BLUE = 1;
    var GREEN = 2;
    var RED = 3;
    var YELLOW = 4;
}

class GameScene extends Scene {
    
    var tilemap:Tilemap;
    var player:Player;
    var collid:Group<Collider>;

    var ldtkName = Tilemaps.WORLD_MAP_GRID_VANIA_LAYOUT;
    
    var columns = 8;
    var rows = 8;
    var map = [
        0,0,1,1,0,0,0,0,
        0,0,1,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,9,0,0,0,0,
        0,0,0,0,0,2,0,0,
        0,0,0,0,0,0,0,0,
        0,0,3,0,0,0,0,0,
        0,0,0,0,0,0,0,0
        ];
    var quadList:Array<Quad>;

    override function preload() {
        // assets.add(Images.TILES);
        assets.add(Images.CHARACTERS);
        // assets.add(Tilemap.TILEMAP);
        assets.add(ldtkName);
    }

    override function create() {
        // assets.texture(Images.TILES).filter = NEAREST;
        assets.texture(Images.CHARACTERS).filter = NEAREST;

        initMockMap();
        // initMap();
        initPlayer();
    }

    override function update(delta:Float) {
        super.update(delta);

        // final index_old = y * columns + x;
        final index = Math.floor(player.x/16) + Math.floor(player.y/16);
        final tile:TileKind = map[index];

        // si bombe en attente


        if(tile == GROUND) {
            // trace("I'm on the ground !");
        }
        
        if(tile == BLUE) {
            // trace("I'm on the wall !");
        }
    }

    function initMap() {
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
        player = new Player(assets, map);
        player.depth = 10;

        player.pos(0,0);
        add(player);

        player.onceBombExplode(this, wallExplosed);
    }

    function wallExplosed(posX:Int, posY:Int) {
        final index = Math.floor(posX/16) + Math.floor(posY/16);

        trace(map);
        explodedWallProx(map[index], index);
        map[index] = TileKind.GROUND;
        trace(index);
        trace(map);
        /*var quadB = quadList[index];
        quadB.color = Color.RED;*/
    }

    function explodedWallProx(typeWall:Int, index:Int) {
        var row = index % 8;
        var col = Math.floor(index / 8);

        var indexL = row - 1;
        var indexR = row + 1;
        while (indexL < 0 || indexR < 8) {
            if (indexL < 0) {
                if(map[indexL] == typeWall) {
                    map[indexL] = GROUND;
                }
                indexL -= 1;
            }
            
            if (indexR < 8) {
                if(map[indexR] == typeWall) {
                    map[indexR] = GROUND;
                }
                indexR += 1;
            }
        }
    }
    // si joueur alors joueur explose
    // etape 1 : explose les murs alentour (x+-1 y+-1) : sans couleur
    // etape 2 : explose tous les murs de la mêmes couleur sur la même ligne 
    // modification du tableau du niveau : quand mur explosé, deviens sol 

    function initMockMap() {
        quadList = new Array<Quad>();
        
        // wall
        var quad1 = new Quad();
        quad1.size(16, 16);
        quad1.pos(48, 0);
        quad1.color = Color.BLUE;
        quad1.anchor(0,0);

        // ground
        var quad2 = new Quad();
        quad2.size(16, 16);
        quad2.pos(0, 0);
        quad2.color = Color.YELLOW;
        quad2.anchor(0,0);
        
        // wall
        var quad3 = new Quad();
        quad3.size(16, 16);
        quad3.pos(32, 0);
        quad3.color = Color.BLUE;
        quad3.anchor(0,0);

        // ground
        var quad4 = new Quad();
        quad4.size(16, 16);
        quad4.pos(16, 0);
        quad4.color = Color.YELLOW;
        quad4.anchor(0,0);
        

        add(quad4);
        quadList.push(quad4);
        add(quad2);
        quadList.push(quad2);

        add(quad1);
        quadList.push(quad1);
        add(quad3);
        quadList.push(quad3);

    }
}