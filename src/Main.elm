port module Main exposing (main)

import Game exposing (World, document)
import Math.Vector2 exposing (vec2)
import World.Component as Component
import World.RenderSystem
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
    World.RenderSystem.preview common ( ecs, objLayer )


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
    , objects = Component.objects.empty
    }


system world_ =
    world_
        |> System.autoScrollCamera (vec2 2 0) (vec2 0 5)
        |> System.linearMovement Component.positions.spec Component.direction.spec
