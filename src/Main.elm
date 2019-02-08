module Main exposing (main)

import Ease exposing (Easing)
import Game exposing (World, document)
import List.Nonempty as NE exposing (Nonempty(..))
import Logic.GameFlow as Flow
import Math.Vector3 exposing (vec3)
import World.Component as Component
import World.Input exposing (keyboard1)
import World.RenderSystem exposing (customSystem)
import World.System as System


main =
    document
        { init = init
        , system = system
        , read = read
        , view = view
        , subscriptions = keyboard1.sub
        }


view common ( world, info ) =
    customSystem common ( world, info )


read =
    [ Component.positions.read
    , Component.dimensions.read
    , Component.objects.read
    , keyboard1.read
    ]


init =
    --TODO rename to world
    { positions = Component.positions.empty
    , dimensions = Component.dimensions.empty
    , direction = keyboard1.empty
    }


system world =
    let
        cameraPoints =
            Nonempty
                (vec3 30 5 360)
                [-- vec3 200 100 360
                 -- , vec3 3 0 160
                 -- , vec3 4 0 160
                 -- , vec3 5 0 160
                ]

        easing =
            Ease.bezier 0.645 0.045 0.355 1
    in
    world
        |> System.demoCamera easing cameraPoints
        |> System.linearMovement Component.positions.spec keyboard1.spec
