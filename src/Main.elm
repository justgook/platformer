port module Main exposing (main, onscreenSpecExtend)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Browser.Dom as Browser
import Browser.Events as Events
import Json.Decode as Decode exposing (Value)
import Logic.Component
import Logic.Component.Singleton
import Logic.Entity
import Logic.GameFlow as Flow
import Logic.Launcher as Launcher exposing (Launcher, document)
import Logic.Template.Camera
import Logic.Template.Camera.PositionLocking
import Logic.Template.Camera.Trigger exposing (Trigger)
import Logic.Template.Component.AnimationDict
import Logic.Template.Component.Layer
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Physics
import Logic.Template.Component.Sprite
import Logic.Template.FX.Projectile as Projectile exposing (Projectile)
import Logic.Template.Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Internal exposing (pxToScreen)
import Logic.Template.OnScreenControl as OnScreenControl
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad.AnimationDict
import Logic.Template.SaveLoad.Camera
import Logic.Template.SaveLoad.Input
import Logic.Template.SaveLoad.Physics
import Logic.Template.SaveLoad.Sprite
import Logic.Template.SaveLoad.Task as TiledRead
import Math.Vector2
import Physic.AABB as AABB
import Physic.Narrow.AABB as AABB
import Set
import Task
import WebGL
import World.System.AnimationChange
import World.System.Physics
import World.View.RenderSystem


read =
    [ Logic.Template.SaveLoad.Sprite.read Logic.Template.Component.Sprite.spec
    , Logic.Template.SaveLoad.AnimationDict.read Logic.Template.Component.AnimationDict.spec
    , Logic.Template.SaveLoad.Input.read Logic.Template.Input.spec
    , Logic.Template.SaveLoad.Camera.readId Logic.Template.Camera.spec
    , RenderInfo.read RenderInfo.spec
    , aabb.read
    ]


type alias OwnWorld =
    { camera : Logic.Template.Camera.WithId (Trigger {})
    , layers : List Logic.Template.Component.Layer.Layer
    , sprites : Logic.Component.Set Logic.Template.Component.Sprite.Sprite
    , physics : AABB.World Int
    , animations : Logic.Component.Set Logic.Template.Component.AnimationDict.AnimationDict
    , input : Logic.Template.Input.Direction
    , projectile : Projectile
    , render : RenderInfo
    , onScreen : TwoButtonStick {}
    }


world : Launcher.World OwnWorld
world =
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , layers = Logic.Template.Component.Layer.empty
    , camera = { viewportOffset = vec2 0 200, id = 0, yTarget = 0 }
    , sprites = Logic.Template.Component.Sprite.empty
    , animations = Logic.Template.Component.AnimationDict.empty
    , input = Logic.Template.Input.empty
    , physics = aabb.empty
    , projectile = Projectile.empty
    , render = RenderInfo.empty
    , onScreen = OnScreenControl.emptyTwoButtonStick
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
                    , Events.onResize (RenderInfo.resize RenderInfo.spec w)
                    ]
        , init = init
        }



--init : Value -> Task.Task Launcher.Error (Launcher.World OwnWorld)


init flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"
    in
    Task.map2
        (\{ scene } w ->
            RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
        )
        Browser.getViewport
        (TiledRead.load Logic.Template.Component.Layer.spec levelUrl world read)



-- Not works with intellij elm plugin
--view : List (VirtualDom.Attribute msg) -> Launcher.World OwnWorld -> List (VirtualDom.Node msg)


view w =
    let
        { renderable } =
            w.projectile

        fxUniforms =
            { renderable
                | aspectRatio = toFloat w.render.screen.width / toFloat w.render.screen.height
                , viewportOffset =
                    w.camera.viewportOffset
                        |> Vec2.scale w.render.px
                        |> Math.Vector2.fromRecord
            }

        newOffset =
            pxToScreen w.render.px w.camera.viewportOffset

        updatedWorld =
            { w | render = RenderInfo.updateOffset newOffset w.render }
    in
    [ Logic.Template.Component.Layer.draw (objRender updatedWorld) updatedWorld
        --        ++ aabb.view updatedWorld.render updatedWorld []
        ++ Projectile.draw fxUniforms
        |> WebGL.toHtmlWith webGLOption (RenderInfo.canvas w.render)
    , OnScreenControl.twoButtonStick onscreenSpecExtend updatedWorld
    ]


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor (29 / 255) (33 / 255) (45 / 255) 1
    ]


onscreenSpecExtend :
    Logic.Component.Singleton.Spec (TwoButtonStick {})
        { world
            | onScreen : TwoButtonStick {}
            , input : Logic.Template.Input.Direction
            , camera : Logic.Template.Camera.WithId (Trigger {})
        }
onscreenSpecExtend =
    { get = OnScreenControl.spec.get
    , set =
        \comp w ->
            let
                jump =
                    if comp.button2.active then
                        Set.insert "Jump"

                    else
                        Set.remove "Jump"

                setXY { x, y } a =
                    { a | x = x, y = y }

                aaa =
                    setXY (OnScreenControl.dir8 comp.center comp.cursor)
            in
            OnScreenControl.spec.set comp w
                |> Logic.Component.Singleton.update (Logic.Template.Input.getComps Logic.Template.Input.spec)
                    (Logic.Component.mapById (\key -> aaa { key | action = jump key.action }) w.camera.id)
    }


objRender w objLayer =
    []
        |> World.View.RenderSystem.viewSprite
            (aabb.compsExtracter w)
            (Logic.Template.Component.Sprite.spec.get w)
            aabb.getPosition
            ( w, objLayer )



-- Not works with intellij elm plugin
--update : Launcher.World OwnWorld -> Launcher.World OwnWorld


update w =
    let
        pixelsPerUnit =
            1.0 / w.render.px

        target_ =
            getPosById w.camera.id w

        target =
            target_
                |> (\a -> Vec2.sub a (getCenter w))

        targetInRelSpace =
            Vec2.vec2 (target_.x / pixelsPerUnit / 2) (target_.y / pixelsPerUnit / 2)

        contactForCamera =
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
            Logic.Template.Camera.Trigger.yTrigger 3 contactForCamera target
                >> Logic.Template.Camera.PositionLocking.xLock target
    in
    { w
        | projectile = Projectile.update { position = targetInRelSpace } w.projectile
    }
        |> World.System.Physics.applyInput (vec2 3 8) Logic.Template.Input.spec aabb.spec
        |> aabb.system
        |> World.System.AnimationChange.sideScroll aabb.spec Logic.Template.Component.Sprite.spec Logic.Template.Component.AnimationDict.spec
        |> Logic.Template.Camera.system Logic.Template.Camera.spec cameraStep


aabb =
    let
        empty =
            Logic.Template.Component.Physics.empty
    in
    { spec = Logic.Template.Component.Physics.spec
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , view = World.View.RenderSystem.debugPhysicsAABB
    , system = World.System.Physics.aabb Logic.Template.Component.Physics.spec
    , read = Logic.Template.SaveLoad.Physics.read Logic.Template.Component.Physics.spec
    , getPosition = AABB.getPosition
    , compsExtracter = \ecs -> ecs.physics |> AABB.getIndexed |> Logic.Entity.fromList
    }


getPosById id =
    aabb.spec.get
        >> AABB.byId id
        >> Maybe.map AABB.getPosition
        >> Maybe.withDefault (vec2 0 0)


getCenter w =
    let
        aspectRatio =
            toFloat w.render.screen.width / toFloat w.render.screen.height

        pixelsPerUnit =
            1.0 / w.render.px
    in
    { x = 0.5 / w.render.px * aspectRatio
    , y = 0.5 / w.render.px
    }
