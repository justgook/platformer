module Game.Logic.Entity exposing (spawnCollectable, spawnPlayer, spawnWall)

import Game.Logic.World as World exposing (World)
import Keyboard.Extra exposing (Direction(..), Key(ArrowDown, ArrowLeft, ArrowRight, ArrowUp))
import QuadTree
import Slime exposing ((&=>))
import Util.KeysToDir exposing (arrows)


spawnWall : { a | height : Float, width : Float, x : Float, y : Float } -> World -> World
spawnWall { x, y, width, height } world =
    Slime.forNewEntity world
        &=> ( World.boundingBoxes, { boundingBox = QuadTree.boundingBox x (x + width) y (y + height) } )
        |> Tuple.second


spawnCollectable : { a | name : String, height : Float, width : Float, x : Float, y : Float } -> World -> World
spawnCollectable ({ x, y, width, height, name } as data) world =
    Slime.forNewEntity world
        &=> ( World.sprites, { name = name } )
        &=> ( World.boundingBoxes, { boundingBox = QuadTree.boundingBox x (x + width) y (y + height) } )
        |> Tuple.second


spawnPlayer : { a | name : String, height : Float, width : Float, x : Float, y : Float } -> World -> World
spawnPlayer ({ x, y, width, height, name } as data) world =
    let
        ( _, updatedWorld ) =
            Slime.forNewEntity world
                &=> ( World.sprites, { name = name } )
                &=> ( World.jumps, { maxHight = 64, startHeight = 0 } )
                &=> ( World.velocities
                    , { vx = 0
                      , vy = 0
                      , speed = 100
                      , acc = 200
                      , maxSpeed = 500
                      }
                    )
                &=> ( World.boundingBoxes, { boundingBox = QuadTree.boundingBox x (x + width) y (y + height) } )
                &=> ( World.inputs
                    , { x = 0
                      , y = 0
                      , parse = arrows { left = ArrowLeft, up = ArrowUp, right = ArrowRight, down = ArrowDown }
                      }
                    )
                &=> ( World.collisions
                    , { top = False
                      , right = False
                      , bottom = False -- onGround
                      , left = False
                      }
                    )
    in
    updatedWorld
