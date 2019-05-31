module Logic.Template.Game.Platformer exposing (World, decode, encode, game, load)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Browser.Dom as Browser
import Browser.Events as Events
import Bytes exposing (Bytes)
import Logic.Component.Singleton
import Logic.Entity
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.System as System
import Logic.Template.Camera
import Logic.Template.Camera.PositionLocking
import Logic.Template.Camera.Trigger exposing (Trigger)
import Logic.Template.Component.Layer
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Physics
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Component.TimeLine as TimeLine
import Logic.Template.Component.TimeLineDict as TimeLineDict exposing (TimeLineDict)
import Logic.Template.FX.Projectile as Projectile exposing (Projectile)
import Logic.Template.Game.Platformer.Common exposing (PlatformerWorld, decoders, emptyWorld, encoders, read)
import Logic.Template.Game.Platformer.RenderSystem exposing (debugPhysicsAABB)
import Logic.Template.Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Internal exposing (pxToScreen)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Layer exposing (lutCollector)
import Logic.Template.System.Control as Control
import Logic.Template.System.TimelineChange as TimelineChange
import Math.Vector2
import Physic.AABB as AABB
import Physic.Narrow.AABB as AABB
import Set
import Task exposing (Task)
import WebGL


type alias World =
    PlatformerWorld


game : Launcher.Document flags PlatformerWorld
game =
    { update = update
    , view = view
    , subscriptions = subscriptions
    , init = \_ -> load "default.json"
    }


encode : String -> Task.Task Launcher.Error ( Bytes, PlatformerWorld )
encode levelUrl =
    SaveLoad.loadTiledAndEncode levelUrl emptyWorld read encoders lutCollector
        |> ResourceTask.toTask


decode : Bytes -> Task Launcher.Error (Launcher.World PlatformerWorld)
decode bytes =
    let
        worldTask =
            SaveLoad.loadBytes bytes emptyWorld decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


load : String -> Task Launcher.Error (Launcher.World PlatformerWorld)
load levelUrl =
    let
        worldTask =
            SaveLoad.loadTiled levelUrl emptyWorld read
    in
    setInitResize worldTask


setInitResize =
    Task.map2
        (\{ scene } w ->
            RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
        )
        Browser.getViewport


subscriptions w =
    Sub.batch
        [ Keyboard.sub Logic.Template.Input.spec w
        , Events.onResize (RenderInfo.resize RenderInfo.spec w)
        ]



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
            , input : Logic.Template.Input.InputSingleton
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

                componentUpdaterInternal =
                    setXY (OnScreenControl.dir8 comp.center comp.cursor)
            in
            OnScreenControl.spec.set comp w
                |> Logic.Component.Singleton.update (Logic.Template.Input.getComps Logic.Template.Input.spec)
                    (Logic.Entity.mapComponentSet (\key -> componentUpdaterInternal { key | action = jump key.action }) w.camera.id)
    }


objRender w ( _, objLayer ) =
    System.indexedFoldl3
        (\i _ c1 sprite acc ->
            acc
                |> (::)
                    (Sprite.draw
                        w.render
                        (case Logic.Entity.getComponent i w.timelines of
                            Just t ->
                                { sprite
                                    | uP =
                                        c1
                                            |> AABB.getPosition
                                            |> (\{ x, y } -> { x = toFloat (round x), y = toFloat (round y) })
                                            |> Math.Vector2.fromRecord
                                    , uIndex = TimeLine.get w.frame t
                                    , uMirror = t.uMirror
                                }

                            Nothing ->
                                { sprite
                                    | uP = c1 |> AABB.getPosition |> Math.Vector2.fromRecord
                                }
                        )
                    )
        )
        objLayer
        (aabb.compsExtracter w)
        w.sprites
        []


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
        |> Control.jumper (vec2 3 8) Logic.Template.Input.spec aabb.spec
        |> aabb.system
        |> TimelineChange.sideScroll TimeLineDict.spec aabb.spec TimeLine.spec
        --        |> World.System.AnimationChange.sideScroll aabb.spec Sprite.spec Logic.Template.Component.AnimationDict.spec
        |> Logic.Template.Camera.system Logic.Template.Camera.spec cameraStep
        |> (\m ->
                let
                    cmd =
                        --                          if m.frame == 60 then
                        --                            SaveLoad.load Logic.Template.Component.Layer.spec
                        --                                "./assets/demo.json"
                        --                                world
                        --                                read
                        --                                |> Launcher.task
                        --                                    (\r w_ ->
                        --                                        case r of
                        --                                            Ok newW ->
                        --                                                { newW
                        --                                                    | render = w_.render
                        --                                                    , physics = w_.physics
                        --                                                    , camera = w_.camera
                        --                                                    , input = w_.input
                        --                                                }
                        --
                        --                                            Err _ ->
                        --                                                w_
                        --                                    )
                        --
                        --                        else
                        Cmd.none
                in
                ( m, cmd )
           )


aabb =
    let
        empty =
            Logic.Template.Component.Physics.empty
    in
    { spec = Logic.Template.Component.Physics.spec
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , view = debugPhysicsAABB
    , system = Control.aabb Logic.Template.Component.Physics.spec
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
