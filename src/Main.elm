port module Main exposing (main)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Browser.Dom as Browser
import Browser.Events as Events
import Defaults exposing (default)
import Json.Decode as Decode exposing (Value)
import Logic.Component
import Logic.Entity
import Logic.GameFlow as Flow
import Logic.Launcher as Launcher exposing (Launcher, document)
import Logic.Template.AnimationDict
import Logic.Template.Camera
import Logic.Template.Camera.PositionLocking
import Logic.Template.Camera.Trigger exposing (Trigger)
import Logic.Template.FX.Projectile as Projectile exposing (Projectile)
import Logic.Template.Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Internal exposing (pxToScreen)
import Logic.Template.Layer
import Logic.Template.Physics
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.Resize as Resize exposing (Resize)
import Logic.Template.SpriteComponent
import Logic.Template.TiledRead.AnimationDict
import Logic.Template.TiledRead.Camera
import Logic.Template.TiledRead.Input
import Logic.Template.TiledRead.Physics
import Logic.Template.TiledRead.Sprite
import Logic.Template.TiledRead.Task as TiledRead
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2
import Physic.AABB as AABB
import Physic.Narrow.AABB as AABB
import Task
import WebGL
import World.System.AnimationChange
import World.System.Physics
import World.View.RenderSystem


read =
    [ Logic.Template.TiledRead.Sprite.read Logic.Template.SpriteComponent.spec
    , Logic.Template.TiledRead.AnimationDict.read Logic.Template.AnimationDict.spec
    , Logic.Template.TiledRead.Input.read Logic.Template.Input.spec
    , Logic.Template.TiledRead.Camera.readId Logic.Template.Camera.spec
    , RenderInfo.read RenderInfo.spec
    , aabb.read
    ]


type alias OwnWorld =
    { camera : Logic.Template.Camera.WithId (Trigger {})
    , layers : List Logic.Template.Layer.Layer
    , sprites : Logic.Component.Set Logic.Template.SpriteComponent.Sprite
    , physics : AABB.World Int
    , animations : Logic.Component.Set Logic.Template.AnimationDict.AnimationDict
    , input : Logic.Template.Input.Direction
    , env : Resize {}
    , projectile : Projectile
    , viewport : Mat4
    , render : RenderInfo
    }


world : Launcher.World OwnWorld
world =
    { env = Resize.empty
    , frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , layers = Logic.Template.Layer.empty
    , camera =
        { pixelsPerUnit = default.pixelsPerUnit
        , viewportOffset = default.viewportOffset
        , id = 0
        , yTarget = 0
        }
    , sprites = Logic.Template.SpriteComponent.empty
    , animations = Logic.Template.AnimationDict.empty
    , input = Logic.Template.Input.empty
    , physics = aabb.empty
    , projectile = Projectile.empty
    , viewport = Mat4.makeOrtho2D 0 2.2 0 1
    , render = RenderInfo.empty

    --    ,viewport = mat4(
    --                (2.0 / aspectRatio), 0, 0, 0,
    --    		 	                 0, 2, 0, 0,
    --    		 			         0, 0,-1, 0,
    --    		 			        -1,-1, 0, 1);
    }


main : Launcher Value OwnWorld
main =
    document
        { update = update
        , view = view
        , subscriptions =
            \w ->
                Sub.batch
                    [ Keyboard.sub Logic.Template.Input.spec w
                    , Resize.sub Resize.spec w
                    , Events.onResize (RenderInfo.resize RenderInfo.spec w)
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
    Task.map2
        (\{ scene } w ->
            RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
                |> Resize.apply Resize.spec scene
        )
        Browser.getViewport
        (TiledRead.load levelUrl world read)



-- Not works with intellij elm plugin
--view : List (VirtualDom.Attribute msg) -> Launcher.World OwnWorld -> List (VirtualDom.Node msg)


view w =
    let
        { renderable } =
            w.projectile

        px =
            1.0 / w.camera.pixelsPerUnit

        fxUniforms =
            { renderable
                | aspectRatio = w.env.aspectRatio
                , viewportOffset =
                    w.camera.viewportOffset
                        |> Vec2.scale px
                        |> Math.Vector2.fromRecord
            }

        render_ =
            w.render

        newOffset =
            pxToScreen w.render.px w.camera.viewportOffset

        render =
            { render_
                | absolute = RenderInfo.setOffsetVec newOffset w.render.absolute
                , offset = newOffset
            }
    in
    [ Logic.Template.Layer.draw objRender { w | render = render }
        ++ Projectile.draw fxUniforms
        |> WebGL.toHtmlWith default.webGLOption (Resize.canvasStyle w.env)
    ]


objRender common ( ecs, objLayer ) =
    []
        --        |> aabb.view common ( ecs, objLayer )
        |> World.View.RenderSystem.viewSprite
            (aabb.compsExtracter ecs)
            (Logic.Template.SpriteComponent.spec.get ecs)
            aabb.getPosition
            common
            ( ecs, objLayer )



-- Not works with intellij elm plugin
--update : Launcher.World OwnWorld -> Launcher.World OwnWorld


update w =
    let
        target_ =
            getPosById w.camera.id w

        target =
            target_
                |> (\a -> Vec2.sub a (getCenter w))

        targetInRelSpace =
            Vec2.vec2 (target_.x / w.camera.pixelsPerUnit / 2) (target_.y / w.camera.pixelsPerUnit / 2)

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
            Logic.Template.Camera.Trigger.yTrigger 3 contact target
                >> Logic.Template.Camera.PositionLocking.xLock target
    in
    { w
        | projectile = Projectile.update { position = targetInRelSpace } w.projectile
    }
        |> World.System.Physics.applyInput (vec2 3 8) Logic.Template.Input.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec Logic.Template.SpriteComponent.spec Logic.Template.AnimationDict.spec
        |> Logic.Template.Camera.system Logic.Template.Camera.spec cameraStep


aabb =
    let
        empty =
            Logic.Template.Physics.empty
    in
    { spec = Logic.Template.Physics.spec
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , view = World.View.RenderSystem.debugPhysicsAABB
    , system = World.System.Physics.aabb Logic.Template.Physics.spec
    , read = Logic.Template.TiledRead.Physics.read Logic.Template.Physics.spec
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
    { x = cam.pixelsPerUnit / 2 * env.aspectRatio
    , y = cam.pixelsPerUnit / 2
    }
