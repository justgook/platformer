port module Main exposing (main, view)

import AltMath.Vector2 exposing (vec2)
import Defaults exposing (default)
import Json.Decode as Decode
import Logic.Asset.AnimationDict
import Logic.Asset.Camera
import Logic.Asset.Input
import Logic.Asset.Layer
import Logic.Asset.Physics
import Logic.Asset.Sprite
import Logic.Component
import Logic.Entity
import Logic.Environment as Environment exposing (Environment)
import Logic.GameFlow as Flow
import Logic.Launcher as Launcher exposing (Launcher, document)
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


read =
    [ Logic.Tiled.Read.Sprite.read Logic.Asset.Sprite.spec
    , Logic.Tiled.Read.AnimationDict.read Logic.Asset.AnimationDict.spec
    , Logic.Tiled.Read.Input.read Logic.Asset.Input.spec
    , Logic.Tiled.Read.Camera.readId Logic.Asset.Camera.spec
    , aabb.read
    ]


type alias OwnWorld =
    { camera : Logic.Asset.Camera.Follow
    , layers : List Logic.Asset.Layer.Layer
    , sprites : Logic.Component.Set Logic.Asset.Sprite.Sprite
    , physics : AABB.World Int
    , animations : Logic.Component.Set Logic.Asset.AnimationDict.AnimationDict
    , direction : Logic.Asset.Input.Direction
    }


main : Launcher OwnWorld
main =
    document
        { update = update
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



-- Not works with intellij elm plugin
--view : List (VirtualDom.Attribute msg) -> Launcher.World OwnWorld -> List (VirtualDom.Node msg)


view style world_ =
    [ World.View.Layer.view objRender world_
        |> WebGL.toHtmlWith default.webGLOption style
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


world : Launcher.World OwnWorld
world =
    { env = Environment.empty
    , frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , layers = Logic.Asset.Layer.empty
    , camera = Logic.Asset.Camera.emptyWithId
    , sprites = Logic.Asset.Sprite.empty
    , animations = Logic.Asset.AnimationDict.empty
    , direction = Logic.Asset.Input.empty
    , physics = aabb.empty
    }


update world_ =
    world_
        |> World.System.Physics.applyInput (vec2 3 8) Logic.Asset.Input.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec Logic.Asset.Sprite.spec Logic.Asset.AnimationDict.spec
        |> World.System.Camera.follow Logic.Asset.Camera.spec getPosById


aabb =
    let
        empty =
            Logic.Asset.Physics.empty
    in
    { spec = Logic.Asset.Physics.spec
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , view = World.View.RenderSystem.debugPhysicsAABB
    , system = World.System.Physics.aabb Logic.Asset.Physics.spec
    , read = Logic.Tiled.Read.Physics.read Logic.Asset.Physics.spec
    , getPosition = AABB.getPosition
    , compsExtracter = \ecs -> ecs.physics |> AABB.getIndexed |> Logic.Entity.fromList
    }


getPosById id =
    aabb.spec.get
        >> AABB.byId id
        >> Maybe.map AABB.getPosition
        >> Maybe.withDefault (vec2 0 0)
