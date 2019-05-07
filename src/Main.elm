port module Main exposing (main)

import AltMath.Vector2 exposing (vec2)
import Defaults exposing (default)
import Game exposing (World, document)
import Json.Decode as Decode
import Logic.Asset.AnimationDict
import Logic.Asset.Camera
import Logic.Asset.Input
import Logic.Asset.Layer
import Logic.Asset.Physics
import Logic.Asset.Sprite
import Logic.Entity
import Logic.Tiled.Read.AnimationDict
import Logic.Tiled.Read.Camera
import Logic.Tiled.Read.Input
import Logic.Tiled.Read.Physics
import Logic.Tiled.Read.Sprite
import Logic.Tiled.Task
import Physic.AABB as AABB
import Physic.Narrow.AABB as AABB
import WebGL
import World.Subscription exposing (keyboard)
import World.System.AnimationChange
import World.System.Camera
import World.System.Physics
import World.View.Layer
import World.View.RenderSystem


main =
    document
        { world = world
        , update = update
        , read = read
        , view = view
        , subscriptions = keyboard
        , init =
            \flags ->
                let
                    levelUrl =
                        flags
                            |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                            |> Result.withDefault "default.json"
                in
                Logic.Tiled.Task.load levelUrl world read
        }



--https://opengameart.org/content/terrain-transitions


aabb =
    let
        empty =
            Logic.Asset.Physics.empty
    in
    { spec = Logic.Asset.Physics.spec
    , view = World.View.RenderSystem.debugPhysicsAABB
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , system = World.System.Physics.aabb Logic.Asset.Physics.spec
    , read = Logic.Tiled.Read.Physics.read Logic.Asset.Physics.spec
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
            (Logic.Asset.Sprite.spec.get ecs)
            aabb.getPosition
            common
            ( ecs, objLayer )


read =
    [ Logic.Tiled.Read.Sprite.read Logic.Asset.Sprite.spec
    , Logic.Tiled.Read.AnimationDict.read Logic.Asset.AnimationDict.spec
    , Logic.Tiled.Read.Input.read Logic.Asset.Input.spec
    , Logic.Tiled.Read.Camera.readId Logic.Asset.Camera.spec
    , aabb.read
    ]


world =
    { direction = Logic.Asset.Input.empty
    , sprites = Logic.Asset.Sprite.empty
    , animations = Logic.Asset.AnimationDict.empty
    , physics = aabb.empty
    , camera = Logic.Asset.Camera.emptyWithId
    , layers = Logic.Asset.Layer.empty
    }


update world_ =
    world_
        |> World.System.Physics.applyInput (vec2 1 8) Logic.Asset.Input.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec Logic.Asset.Sprite.spec Logic.Asset.AnimationDict.spec
        |> World.System.Camera.follow Logic.Asset.Camera.spec getPosById


getPosById id =
    aabb.spec.get
        >> AABB.byId id
        >> Maybe.map AABB.getPosition
        >> Maybe.withDefault (vec2 0 0)
