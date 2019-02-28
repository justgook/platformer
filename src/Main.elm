port module Main exposing (main)

import Game exposing (World, document)
import World.Component as Component
import World.Component.Collision
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



--https://opengameart.org/content/terrain-transitions


view common ( ecs, objLayer ) =
    World.RenderSystem.preview common ( ecs, objLayer )
        |> World.RenderSystem.debugQadtree common ( ecs, objLayer )


read =
    [ Component.positions.read
    , Component.dimensions.read
    , Component.objects.read
    , Component.direction.read
    , Component.animations.read
    ]


world =
    { positions = Component.positions.empty
    , dimensions = Component.dimensions.empty
    , direction = Component.direction.empty
    , objects = Component.objects.empty
    , animations = Component.animations.empty
    , collisions = World.Component.Collision.collisions.empty
    }


system world_ =
    world_
        --        |> System.autoScrollCamera (vec2 1 0) (vec2 0 5)
        |> System.linearMovement Component.positions.spec Component.direction.spec
