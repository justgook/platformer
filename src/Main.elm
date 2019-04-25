port module Main exposing (main)

import AltMath.Vector2 exposing (vec2)
import Defaults exposing (default)
import Develop exposing (World, document)
import Layer
import Logic.Entity
import Physic.AABB as AABB
import Physic.Narrow.AABB as AABB
import WebGL
import World.Component as Component
import World.Component.Camera
import World.Component.Physics
import World.RenderSystem
import World.Subscription exposing (keyboard)
import World.System.AnimationChange
import World.System.Camera
import World.System.Physics


main =
    document
        { world = world
        , system = system
        , read = read
        , view = view
        , subscriptions = keyboard
        }



--https://opengameart.org/content/terrain-transitions


aabb =
    let
        delme =
            World.Component.Physics.aabb

        empty =
            delme.empty
    in
    { spec = delme.spec
    , view = World.RenderSystem.debugPhysicsAABB
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , system = World.System.Physics.aabb delme.spec
    , read = delme.read
    , getPosition = AABB.getPosition
    , compsExtracter = \ecs -> ecs.physics |> AABB.getIndexed |> Logic.Entity.fromList
    }


view style common ecs =
    [ Layer.view objRender common ecs |> WebGL.toHtmlWith default.webGLOption style ]


objRender common ( ecs, objLayer ) =
    []
        --        |> aabb.view common ( ecs, objLayer )
        |> World.RenderSystem.viewSprite aabb.compsExtracter aabb.getPosition common ( ecs, objLayer )


read =
    [ Component.positions.read
    , Component.dimensions.read
    , Component.sprites.read
    , Component.direction.read
    , Component.animations.read
    , aabb.read
    , World.Component.Camera.target.read
    ]


world =
    { positions = Component.positions.empty
    , dimensions = Component.dimensions.empty
    , direction = Component.direction.empty
    , sprites = Component.sprites.empty
    , animations = Component.animations.empty
    , physics = aabb.empty
    , camera = World.Component.Camera.target.empty
    }


system world_ =
    world_
        |> World.System.Physics.applyInput (vec2 3 8) Component.direction.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec Component.sprites.spec Component.animations.spec
        |> World.System.Camera.follow World.Component.Camera.target.spec getPosById


getPosById id =
    aabb.spec.get
        >> AABB.byId id
        >> Maybe.map AABB.getPosition
        >> Maybe.withDefault (vec2 0 0)
