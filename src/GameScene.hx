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

        var bomb = new Bomb(assets);
        bomb.pos(
            row * TILE_SIZE,
            col * TILE_SIZE
        );

        bomb.depth = player.depth;
        container.add(bomb);
        bomb.animation = "EXPLOSION_RED_LOOP";
        
        var bombRayL = new Bomb(assets);
        bombRayL.pos(
            (row-1) * TILE_SIZE,
            col * TILE_SIZE
        );
        bombRayL.depth = player.depth;
        bombRayL.scaleX = 0;
        container.add(bombRayL);
        bombRayL.animation = 'EXPLOSION_RED_RAY';
        
        var bombRayR = new Bomb(assets);
        bombRayR.pos(
            (row+1) * TILE_SIZE,
            col * TILE_SIZE
        );
        bombRayR.depth = player.depth;
        bombRayR.scaleX = 0;
        container.add(bombRayR);
        bombRayR.animation = 'EXPLOSION_RED_RAY';

        
        var bombRayUp = new Bomb(assets);
        bombRayUp.pos(
            row * TILE_SIZE,
            (col-1) * TILE_SIZE
        );
        bombRayUp.anchor(0, 1);
        bombRayUp.rotation = 90;
        bombRayUp.depth = player.depth;
        bombRayUp.scaleX = 0;
        container.add(bombRayUp);
        bombRayUp.animation = 'EXPLOSION_RED_RAY';
        
        var bombRayDown = new Bomb(assets);
        bombRayDown.pos(
            row * TILE_SIZE,
            (col+1) * TILE_SIZE
        );
        bombRayDown.anchor(0, 1);
        bombRayDown.rotation = 90;
        bombRayDown.depth = player.depth;
        bombRayDown.scaleX = 0;
        container.add(bombRayDown);
        bombRayDown.animation = 'EXPLOSION_RED_RAY';


        explodedWallProx(BLUE, row, col, bomb, bombRayL, bombRayR, bombRayUp, bombRayDown);
        levelData.map[indexT] = TileKind.GROUND;
    }

    function explodedWallProx(typeWall:TileKind, row:Int, col:Int, bomb:Bomb, bombRayL:Bomb, bombRayR:Bomb, bombRayUp:Bomb, bombRayDown:Bomb) {
        var noWallExplosedL = false;
        var noWallExplosedR = false;
        var noWallExplosedUp = false;
        var noWallExplosedDown = false;

        var rowL = row - 1;
        var rowR = row + 1;
        var colUp = col - 1;
        var colDown = col + 1;
        
        while(!noWallExplosedL || !noWallExplosedR || !noWallExplosedUp || !noWallExplosedDown) {

        	// gauche
        	if (rowL >= 0) {
        	    var indexL = rowL + col * levelData.columns;
        	    if(levelData.map[indexL] == typeWall) {
        	        var w = walls.items.filter(w -> (w.y == col * TILE_SIZE) && (w.x == rowL * TILE_SIZE))[0];
				
        	        w.animation = "WALL_BLUE_EXPLODE";
				
        	        w.loop = false;
        	        walls.remove(w);
					((w:Wall) -> {
						Timer.delay(this, 0.3, () -> w.destroy());
					})(w);
				
        	        levelData.map[indexL] = GROUND;

        	    }

        	    if(levelData.map[indexL] == typeWall || levelData.map[indexL] == GROUND || levelData.map[indexL] == VOID) {
        	        bombRayL.scaleX += 1;
        	    }
			
        	    rowL -= 1;
        	}
        	else {
        	    noWallExplosedL = true;
        	}
        
        	// droite
        	if (rowR < 8) {
        	    var indexR = rowR + col * levelData.columns;
        	    if(levelData.map[indexR] == typeWall) {
        	        var w = walls.items.filter(w -> (w.y == col * TILE_SIZE) && (w.x == rowR * TILE_SIZE))[0];
        	        w.animation = "WALL_BLUE_EXPLODE";
				
        	        w.loop = false;
        	        walls.remove(w);
					((w:Wall) -> {
						Timer.delay(this, 0.3, () -> w.destroy());
					})(w);
				
        	        levelData.map[indexR] = GROUND;
        	    }
			
        	    if(levelData.map[indexR] == typeWall || levelData.map[indexR] == GROUND || levelData.map[indexR] == VOID) {
        	        bombRayR.scaleX += 1;
        	    }
        	    rowR += 1;
        	}
        	else {
        	    noWallExplosedR = true;
        	}

        	// haut
        	if (colUp >= 0) {
        	    var indexUp = row + colUp * levelData.columns;
        	    if(levelData.map[indexUp] == typeWall) {
        	        var w = walls.items.filter(w -> (w.y == colUp * TILE_SIZE) && (w.x == row * TILE_SIZE))[0];
				
        	        w.animation = "WALL_BLUE_EXPLODE";
				
        	        w.loop = false;
        	        walls.remove(w);
					((w:Wall) -> {
						Timer.delay(this, 0.3, () -> w.destroy());
					})(w);
				
        	        levelData.map[indexUp] = GROUND;
        	    }
			
        	    if(levelData.map[indexUp] == typeWall || levelData.map[indexUp] == GROUND || levelData.map[indexUp] == VOID) {
        	        bombRayUp.scaleX += 1;
        	    }
        	    colUp -= 1;
        	}
        	else {
        	    noWallExplosedUp = true;
        	}

        	// bas
        	if (colDown < 8) {
        	    var indexDown = row + colDown * levelData.columns;
        	    if(levelData.map[indexDown] == typeWall) {
        	        var w = walls.items.filter(w -> (w.y == colDown * TILE_SIZE) && (w.x == row * TILE_SIZE))[0];                   
        	        w.animation = "WALL_BLUE_EXPLODE";
				
        	        w.loop = false;
        	        walls.remove(w);
					((w:Wall) -> {
						Timer.delay(this, 0.3, () -> w.destroy());
					})(w);
				
        	        levelData.map[indexDown] = GROUND;
        	    }
			
        	    if(levelData.map[indexDown] == typeWall || levelData.map[indexDown] == GROUND || levelData.map[indexDown] == VOID) {
        	        bombRayDown.scaleX += 1;
        	    }
        	    colDown += 1;
        	}
        	else {
        	    noWallExplosedDown = true;
        	}
        }

        Timer.delay(this, 0.5, () -> { bomb.destroy(); bombRayL.destroy();  bombRayR.destroy(); bombRayDown.destroy(); bombRayUp.destroy(); });

        var g = grounds.items.filter(g -> (g.y == col * TILE_SIZE) && (g.x == row * TILE_SIZE))[0];
        g.animation = 'GROUND';
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