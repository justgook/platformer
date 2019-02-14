port module Main exposing (main)

--import Json.Encode as E

import Ease exposing (Easing)
import Game exposing (World, document)
import List.Nonempty exposing (Nonempty(..))
import Math.Vector3 exposing (vec3)
import World.Component as Component
import World.RenderSystem exposing (customSystem)
import World.Subscription exposing (keyboard)
import World.System as System


main =
    document
        { init = init
        , system = system
        , read = read
        , view = view
        , subscriptions = keyboard
        }


view common ( world, info ) =
    customSystem common ( world, info )



--port gamepadDown : (E.Value -> msg) -> Sub msg
--
--
--port gamepadUp : (E.Value -> msg) -> Sub msg


read =
    [ Component.positions.read
    , Component.dimensions.read
    , Component.objects.read
    , Component.direction.read
    ]


init =
    --TODO rename to world
    { positions = Component.positions.empty
    , dimensions = Component.dimensions.empty
    , direction = Component.direction.empty
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
        |> System.linearMovement Component.positions.spec Component.direction.spec
