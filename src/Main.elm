port module Main exposing (main, view)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Defaults exposing (default)
import Json.Decode as Decode
import Logic.Asset.AnimationDict
import Logic.Asset.Camera
import Logic.Asset.Camera.PlatformSnapping exposing (PlatformSnapping)
import Logic.Asset.Camera.PositionLocking
import Logic.Asset.Input
import Logic.Asset.Input.Keyboard as Keyboard
import Logic.Asset.Layer
import Logic.Asset.Physics
import Logic.Asset.Resize as Resize exposing (Resize)
import Logic.Asset.Sprite
import Logic.Component
import Logic.Entity
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
import Task
import WebGL
import World.System.AnimationChange
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
    { camera : Logic.Asset.Camera.WithId (PlatformSnapping {})
    , layers : List Logic.Asset.Layer.Layer
    , sprites : Logic.Component.Set Logic.Asset.Sprite.Sprite
    , physics : AABB.World Int
    , animations : Logic.Component.Set Logic.Asset.AnimationDict.AnimationDict
    , input : Logic.Asset.Input.Direction
    , env : Resize {}
    }


main : Launcher OwnWorld
main =
    document
        { update = update
        , view = view
        , subscriptions =
            \w ->
                Sub.batch
                    [ Keyboard.sub Logic.Asset.Input.spec w
                    , Resize.sub Resize.spec w
                    ]
        , init = init
        }


init flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"

        spec =
            { get = .env2
            , set = \comps w -> { w | env2 = comps }
            }
    in
    Task.map2 (Resize.apply Resize.spec) Resize.task (Logic.Tiled.Task.load levelUrl world read)



-- Not works with intellij elm plugin
--view : List (VirtualDom.Attribute msg) -> Launcher.World OwnWorld -> List (VirtualDom.Node msg)


view world_ =
    [ World.View.Layer.view objRender world_
        |> WebGL.toHtmlWith default.webGLOption (Resize.canvasStyle world_.env)
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
    { env = Resize.empty
    , frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , layers = Logic.Asset.Layer.empty
    , camera =
        { pixelsPerUnit = default.pixelsPerUnit
        , viewportOffset = default.viewportOffset
        , id = 0
        , yTarget = 0
        }
    , sprites = Logic.Asset.Sprite.empty
    , animations = Logic.Asset.AnimationDict.empty
    , input = Logic.Asset.Input.empty
    , physics = aabb.empty
    }



-- Not works with intellij elm plugin
--update : Launcher.World OwnWorld -> Launcher.World OwnWorld


update w =
    let
        target =
            getPosById w.camera.id w
                |> (\a -> Vec2.sub a (getCenter w))

        contact =
            aabb.spec.get w
                |> AABB.byId w.camera.id
                |> Maybe.map (AABB.getContact >> .y)
                |> Maybe.andThen
                    (\a ->
                        if a == -1 then
                            Just target.y

                        else
                            Nothing
                    )

        cameraStep =
            Logic.Asset.Camera.PlatformSnapping.step contact target
                >> Logic.Asset.Camera.PositionLocking.xLock target
    in
    w
        |> World.System.Physics.applyInput (vec2 3 8) Logic.Asset.Input.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec Logic.Asset.Sprite.spec Logic.Asset.AnimationDict.spec
        |> Logic.Asset.Camera.system Logic.Asset.Camera.spec cameraStep


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


getCenter world_ =
    let
        env =
            world_.env

        cam =
            world_.camera
    in
    { x = cam.pixelsPerUnit / 2 * env.widthRatio
    , y = cam.pixelsPerUnit / 2
    }
