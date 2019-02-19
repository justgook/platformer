port module Main exposing (main)

--import Json.Encode as E

import Ease exposing (Easing)
import Game exposing (World, document)
import Math.Vector3 exposing (vec3)
import World.Component as Component
import World.RenderSystem exposing (customSystem)
import World.Subscription exposing (keyboard)
import World.System as System


main =
    document
        { world = world
        , system = system
        , read = read
        , view = view
        , subscriptions = keyboard
        }


view common ( ecs, objLayer ) =
    customSystem common ( ecs, objLayer )



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


world =
    { positions = Component.positions.empty
    , dimensions = Component.dimensions.empty
    , direction = Component.direction.empty
    }


system world_ =
    let
        cameraPoints =
            [ vec3 0 0 160

            --            , vec3 150 0 360
            --            , vec3 150 150 360
            --            , vec3 0 150 160
            ]

        easing =
            Ease.bezier 0.645 0.045 0.355 1
    in
    world_
        |> System.demoCamera easing cameraPoints
        |> System.linearMovement Component.positions.spec Component.direction.spec
