package;

import ceramic.Timer;
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
    var bomb:Bomb;

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
    var voids:Group<Wall>;

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
        // assets.texture(Images.CHARACTERS).filter = NEAREST;

        initMap();
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
        app.arcade.world.collide(voids, player);
    }

    function initPlayer() {
        player = new Player(assets, levelData);
        player.depth = 10;

        player.pos(0,0);
        container.add(player);

        
        // bomb = new Bomb(assets);
        // bomb.pos(0,0);

        // bomb.depth = 10;
        // container.add(bomb);
        

        player.onBombDisplay(this, bombDisplay);
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

    
    function bombDisplay(posX:Int, posY:Int) {
        var indexT = Math.floor(posX/16) + Math.floor(posY/16) * levelData.columns;
        var row = indexT % 8;
        var col = Math.floor(indexT / 8);
        
        var g = grounds.items.filter(g -> (g.y == col * TILE_SIZE) && (g.x == row * TILE_SIZE))[0];
        g.animation = 'GROUND_TRIGGER_BLUE';
    }

    // si joueur alors joueur explose
    // etape 1 : explose les murs alentour (x+-1 y+-1) : sans couleur
    // etape 2 : explose tous les murs de la mêmes couleur sur la même ligne
    // modification du tableau du niveau : quand mur explosé, deviens sol
    function wallExplosed(posX:Int, posY:Int) {
        // type de bomb : couleur ?
        
        var indexT = Math.floor(posX/16) + Math.floor(posY/16) * levelData.columns;
        var row = indexT % 8;
        var col = Math.floor(indexT / 8);

        bomb = new Bomb(assets);
        bomb.pos(
            row * TILE_SIZE,
            col * TILE_SIZE
        );

        bomb.depth = player.depth;
        container.add(bomb);
        bomb.animation = "EXPLOSION_RED_LOOP";

        // bomb.animation = 'EXPLOSION_RED_RAY';
        explodedWallProx(BLUE, indexT);
        levelData.map[indexT] = TileKind.GROUND;
    }

    function explodedWallProx(typeWall:TileKind, indexT:Int) {
        var row = indexT % 8;
        var col = Math.floor(indexT / 8);

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
                if(levelData.map[indexT-rowL] == typeWall) {
                    var w = walls.items.filter(w -> (w.y == col * TILE_SIZE) && (w.x == rowL * TILE_SIZE))[0];
                    w.animation = "WALL_BLUE_EXPLODE";
                    w.loop = false;
                    walls.remove(w);
                    Timer.delay(this, 0.3, () -> w.destroy());

                    levelData.map[indexT-rowL] = GROUND;
                    rowL -= 1;
                }
                else {
                    noWallExplosedL = true;
                }
            }

            if (rowR < 8 && !noWallExplosedR) {
                if(levelData.map[indexT+rowR] == typeWall) {
                    var w = walls.items.filter(w -> (w.y == col * TILE_SIZE) && (w.x == rowR * TILE_SIZE))[0];
                    w.animation = "WALL_BLUE_EXPLODE";
                    w.loop = false;
                    walls.remove(w);
                    // w.active = false;
                    Timer.delay(this, 0.3, () -> w.destroy());

                    levelData.map[indexT+rowR] = GROUND;
                    rowR += 1;
                }
                else {
                    noWallExplosedR = true;
                }
            }

            if (colL > 0 && !noWallExplosedUp) {
                if(levelData.map[indexT-colL] == typeWall) {
                    var w = walls.items.filter(w -> (w.y == colL * TILE_SIZE) && (w.x == row * TILE_SIZE))[0];
                    w.animation = "WALL_BLUE_EXPLODE";
                    w.loop = false;
                    walls.remove(w);
                    Timer.delay(this, 0.3, () -> w.destroy());

                    levelData.map[indexT-colL] = GROUND;
                    colL -= 1;
                }
                else {
                    noWallExplosedUp = true;
                }
            }


            if (colR < 8 && !noWallExplosedDown) {
                if(levelData.map[indexT+(colR * 8)] == typeWall) {
                    var w = walls.items.filter(w -> (w.y == colR * TILE_SIZE) && (w.x == row * TILE_SIZE))[0];
                    w.animation = "WALL_BLUE_EXPLODE";
                    w.loop = false;
                    walls.remove(w);
                    Timer.delay(this, 0.3, () -> w.destroy());

                    levelData.map[indexT+colR] = GROUND;
                    colR += 1;
                }
                else {
                    noWallExplosedDown = true;
                }
            }
        }

        // trace(levelData.map);

        // Jérémy : tableau modifié, pas besoin de le ré-assigner
        //player._map = map;
    }

    function initMap() {
        grounds = new Group('ground');
        walls = new Group('wall');
        voids = new Group('voidground');

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
                if(tile == VOID) {
                    // void tile
                    var void = new Wall(assets, tile);
                    void.pos(
                        col * TILE_SIZE,
                        row * TILE_SIZE
                    );
                    void.depth = DEPTH_GROUND + row * levelData.rows + col * 0.1;
                    container.add(void);
                    voids.add(void);
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
    }
}