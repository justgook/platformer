module Game.ECS.Entity exposing (spawnPlayer, spawnWall)

import Game.ECS.Component as Component
import Game.ECS.World as World exposing (World)
import Keyboard.Extra exposing (Direction(..), Key(ArrowDown, ArrowLeft, ArrowRight, ArrowUp))
import Slime exposing ((&=>))
import Util.KeysToDir exposing (arrows)


first : ( a, b, c ) -> a
first ( a, _, _ ) =
    -- http://package.elm-lang.org/packages/Fresheyeball/elm-tuple-extra/3.0.0/Tuple3
    a


spawnWall : Component.Position -> Component.Dimension -> World -> World
spawnWall position dimension world =
    { a = position, b = dimension }
        |> Slime.spawnEntity2 World.positions World.dimensions world
        |> first


spawnPlayer : Component.Position -> Component.Dimension -> World -> World
spawnPlayer position dimension world =
    let
        ( _, updatedWorld ) =
            Slime.forNewEntity world
                &=> ( World.positions, position )
                &=> ( World.velocities
                    , { vx = 0
                      , vy = 0
                      , speed = 100
                      , acc = 200
                      , maxSpeed = 500
                      , direction = NoDirection
                      }
                    )
                &=> ( World.dimensions, dimension )
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
