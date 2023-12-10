package;

import ceramic.Color;
import ceramic.Group;
import ceramic.Quad;
import ceramic.Scene;
import ceramic.Tilemap;
import ceramic.Visual;

using ceramic.SpritePlugin;
using ceramic.TilemapPlugin;

class GameScene extends Scene {

    var tilemap:Tilemap;
    var player:Player;
    var index:Int;

    var ldtkName = Tilemaps.WORLD_MAP_GRID_VANIA_LAYOUT;

    var levelData:LevelData = {
        columns: 8, rows: 8,
        map: [
            0,0,1,1,0,0,0,0,
            0,0,1,0,0,0,0,0,
            0,0,0,0,0,0,0,0,
            0,0,0,9,0,0,0,0,
            0,0,0,0,0,2,0,0,
            0,0,0,0,0,0,0,0,
            0,0,3,0,0,0,0,0,
            0,0,0,0,0,0,0,0
        ]
    };

    var grounds:Group<Ground>;
    var walls:Group<Wall>;

    var container:Visual;

    override function preload() {
        // assets.add(Images.TILES);
        assets.add(Images.CHARACTERS);
        // assets.add(Tilemap.TILEMAP);
        assets.add(ldtkName);

        assets.add(Sprites.BOMBERLIKE_BLOCKS);
        assets.add(Sprites.BOMBERLIKE_CHARACTER);
        assets.add(Sprites.BOMBERLIKE_EXPLOSION);
    }

    override function create() {
        // assets.texture(Images.TILES).filter = NEAREST;
        assets.texture(Images.CHARACTERS).filter = NEAREST;

        initMockMap();
        // initMap();
        initPlayer();
        initPhysics();
    }

    override function update(delta:Float) {
        super.update(delta);

        player.updatePlayer(delta);

        // final index_old = y * columns + x;
        index = Math.floor(player.x/16) + Math.floor(player.y/16) * levelData.columns;
        final tile:TileKind = levelData.map[index];

        // si bombe en attente


        if(tile == GROUND) {
            // trace("I'm on the ground !");
        }

        if(tile == BLUE) {
            // trace("I'm on the wall !");
        }
    }

    function updatePhysics(delta:Float) {

        // Collide walls with player
        app.arcade.world.collide(walls, player);

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

            // trace(level.layerInstances[0].entityInstances[0].def.identifier);
        });
    }

    function initPlayer() {
        player = new Player(assets, levelData);
        player.depth = 10;

        player.pos(0,0);
        container.add(player);

        player.onBombExplode(this, wallExplosed);
    }

    function initPhysics() {

        // We don't want Ceramic to update world bounds from screen.
        // Instead, if set world bounds to match level size
        app.arcade.autoUpdateWorldBounds = false;
        app.arcade.world.setBounds(
            0, 0, levelData.columns * TILE_SIZE, levelData.rows * TILE_SIZE
        );

        // Bind our physics update callback to setup our custom collisions
        app.arcade.offUpdate(updatePhysics);
        app.arcade.onUpdate(this, updatePhysics);

    }

    // si joueur alors joueur explose
    // etape 1 : explose les murs alentour (x+-1 y+-1) : sans couleur
    // etape 2 : explose tous les murs de la mêmes couleur sur la même ligne
    // modification du tableau du niveau : quand mur explosé, deviens sol
    function wallExplosed(posX:Int, posY:Int) {
        // type de bomb : couleur ?
        explodedWallProx(BLUE, index);
        levelData.map[index] = TileKind.GROUND;
    }

    function explodedWallProx(typeWall:TileKind, index:Int) {
        var row = index % 8;
        var col = Math.floor(index / 8);

        var noWallExplosedL = false;
        var noWallExplosedR = false;
        var noWallExplosedUp = false;
        var noWallExplosedDown = false;

        var rowL = row - 1;
        var rowR = row + 1;
        var colL = col - 1;
        var colR = col + 1;

        while (!noWallExplosedL && !noWallExplosedR && !noWallExplosedDown && !noWallExplosedUp) {
            if (rowL > 0 && !noWallExplosedL) {
                if(levelData.map[index-rowL] == typeWall) {
                    levelData.map[index-rowL] = GROUND;
                    rowL -= 1;
                }
                else {
                    noWallExplosedL = true;
                }
            }

            if (rowR < 8 && !noWallExplosedR) {
                trace(levelData.map[index+rowR]);
                if(levelData.map[index+rowR] == typeWall) {
                    levelData.map[index+rowR] = GROUND;
                    rowR += 1;
                }
                else {
                    noWallExplosedR = true;
                }
            }

            if (colL > 0 && !noWallExplosedUp) {
                if(levelData.map[index-colL] == typeWall) {
                    levelData.map[index-colL] = GROUND;
                    colL -= 1;
                }
                else {
                    noWallExplosedUp = true;
                }
            }


            if (colR < 8 && !noWallExplosedDown) {
                if(levelData.map[index+colR] == typeWall) {
                    levelData.map[index+colR] = GROUND;
                    colR += 1;
                }
                else {
                    noWallExplosedDown = true;
                }
            }
        }

        // Jérémy : tableau modifié, pas besoin de le ré-assigner
        //player._map = map;
    }

    function initMockMap() {
        grounds = new Group('ground');
        walls = new Group('wall');

        container = new Visual();
        container.size(levelData.columns * TILE_SIZE, levelData.rows * TILE_SIZE);
        container.anchor(0.5, 0.5);
        container.pos(width * 0.5, height * 0.5);
        add(container);

        for (row in 0...levelData.rows) {
            for (col in 0...levelData.columns) {

                final index = row * levelData.rows + col;
                final tile:TileKind = levelData.map[index];

                if (tile != VOID) {
                    // Ground unless VOID
                    var ground = new Ground(assets);
                    ground.pos(
                        col * TILE_SIZE,
                        row * TILE_SIZE
                    );
                    ground.depth = DEPTH_GROUND + row * levelData.rows + col * 0.1;
                    container.add(ground);
                    grounds.add(ground);
                }

                if (tile == RED || tile == GREEN || tile == BLUE || tile == YELLOW) {
                    // Wall tile
                    var wall = new Wall(assets, tile);
                    wall.pos(
                        col * TILE_SIZE,
                        row * TILE_SIZE
                    );
                    wall.depth = DEPTH_WALL + row * levelData.rows + col * 0.1;
                    container.add(wall);
                    walls.add(wall);
                }

            }
        }

        // // wall
        // var quad1 = new Quad();
        // quad1.size(16, 16);
        // quad1.pos(48, 0);
        // quad1.color = Color.BLUE;
        // quad1.anchor(0,0);

        // // ground
        // var quad2 = new Quad();
        // quad2.size(16, 16);
        // quad2.pos(0, 0);
        // quad2.color = Color.YELLOW;
        // quad2.anchor(0,0);

        // // wall
        // var quad3 = new Quad();
        // quad3.size(16, 16);
        // quad3.pos(32, 0);
        // quad3.color = Color.BLUE;
        // quad3.anchor(0,0);

        // // ground
        // var quad4 = new Quad();
        // quad4.size(16, 16);
        // quad4.pos(16, 0);
        // quad4.color = Color.YELLOW;
        // quad4.anchor(0,0);


        // add(quad4);
        // quadList.push(quad4);
        // add(quad2);
        // quadList.push(quad2);

        // add(quad1);
        // quadList.push(quad1);
        // add(quad3);
        // quadList.push(quad3);

    }
}