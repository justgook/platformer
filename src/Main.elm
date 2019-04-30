port module Main exposing (main)

import AltMath.Vector2 exposing (vec2)
import Defaults exposing (default)
import Develop exposing (World, document)
import Logic.Entity
import Physic.AABB as AABB
import Physic.Narrow.AABB as AABB
import Tiled.Read.AnimationDict
import Tiled.Read.Camera
import Tiled.Read.Input
import Tiled.Read.Sprite
import WebGL
import World.Component.AnimationDict
import World.Component.Camera
import World.Component.Input
import World.Component.Layer
import World.Component.Physics
import World.Component.Sprite
import World.Subscription exposing (keyboard)
import World.System.AnimationChange
import World.System.Camera
import World.System.Physics
import World.View.Layer
import World.View.RenderSystem


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
    , view = World.View.RenderSystem.debugPhysicsAABB
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , system = World.System.Physics.aabb delme.spec
    , read = delme.read
    , getPosition = AABB.getPosition
    , compsExtracter = \ecs -> ecs.physics |> AABB.getIndexed |> Logic.Entity.fromList
    }


view style common ecs =
    [ World.View.Layer.view objRender common ecs
        |> WebGL.toHtmlWith default.webGLOption style

    --    , Nipple.stylesheet
    --    , Nipple.container style Nipple.dir
    ]


objRender common ( ecs, objLayer ) =
    []
        --        |> aabb.view common ( ecs, objLayer )
        |> World.View.RenderSystem.viewSprite
            (aabb.compsExtracter ecs)
            (World.Component.Sprite.spec.get ecs)
            aabb.getPosition
            common
            ( ecs, objLayer )


read =
    [ Tiled.Read.Sprite.read World.Component.Sprite.spec
    , Tiled.Read.AnimationDict.read World.Component.AnimationDict.spec
    , Tiled.Read.Input.read World.Component.Input.spec
    , Tiled.Read.Camera.readId World.Component.Camera.spec
    , aabb.read
    ]


world =
    { direction = World.Component.Input.empty
    , sprites = World.Component.Sprite.empty
    , animations = World.Component.AnimationDict.empty
    , physics = aabb.empty
    , camera = World.Component.Camera.emptyWithId
    , layers = World.Component.Layer.empty
    }


system world_ =
    world_
        |> World.System.Physics.applyInput (vec2 3 8) World.Component.Input.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec World.Component.Sprite.spec World.Component.AnimationDict.spec
        |> World.System.Camera.follow World.Component.Camera.spec getPosById


getPosById id =
    aabb.spec.get
        >> AABB.byId id
        >> Maybe.map AABB.getPosition
        >> Maybe.withDefault (vec2 0 0)
