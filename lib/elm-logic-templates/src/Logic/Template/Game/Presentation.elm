module Logic.Template.Game.Presentation exposing
    ( World
    , decode
    , encode
    , game
    , load
    , run
    )

import AltMath.Vector2 as Vec2 exposing (vec2)
import Browser.Dom as Browser
import Browser.Events as Events
import Bytes exposing (Bytes)
import Collision.Physic.AABB as AABB
import Collision.Physic.Narrow.AABB as AABB
import Logic.Component.Singleton as Singleton
import Logic.Entity
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.System as System
import Logic.Template.Camera
import Logic.Template.Camera.PositionLocking
import Logic.Template.Component.Animation as TimeLine2
import Logic.Template.Component.AnimationsDict as TimeLineDict2
import Logic.Template.Component.Layer
import Logic.Template.Component.Physics
import Logic.Template.Component.SFX as AudioSprite
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Game.Presentation.Common exposing (PresentationWorld, decoders, empty, encoders, read)
import Logic.Template.Game.Presentation.Content2 as Content
import Logic.Template.Game.Presentation.Slide as Slide
import Logic.Template.Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Layer exposing (lutCollector)
import Logic.Template.System.SlideStop exposing (SlideStops, applyInput)
import Logic.Template.System.TimelineChange as TimelineChange
import Math.Vector2
import Task exposing (Task)
import VirtualDom
import WebGL



--ASSETS!!
--https://gumroad.com/l/IDwxw
--https://forums.tigsource.com/index.php?topic=14166.0
--https://www.deviantart.com/madgharr -- super micro characters


type alias World =
    PresentationWorld


game : Launcher.Document flags PresentationWorld
game =
    { update = update
    , view = view
    , subscriptions = subscriptions
    , init = \_ -> load "default.json"
    }


encode : String -> Task.Task Launcher.Error ( Bytes, PresentationWorld )
encode levelUrl =
    SaveLoad.loadTiledAndEncode levelUrl empty read encoders lutCollector
        |> ResourceTask.toTask


decode : Bytes -> Task Launcher.Error (Launcher.World PresentationWorld)
decode bytes =
    let
        worldTask =
            SaveLoad.loadFromBytes bytes empty decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


run : String -> Task Launcher.Error (Launcher.World PresentationWorld)
run levelUrl =
    let
        worldTask =
            SaveLoad.loadBytes levelUrl empty decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


load : String -> Task Launcher.Error (Launcher.World PresentationWorld)
load levelUrl =
    let
        worldTask =
            SaveLoad.loadTiled levelUrl empty read
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


view w =
    let
        playerEntityID =
            w.camera.id

        style =
            RenderInfo.canvas w.render
    in
    [ Logic.Template.Component.Layer.draw (objRender w) w
        |> WebGL.toHtmlWith webGLOption style
    ]
        ++ slides w.slideOpacity style w
        |> (::) (AudioSprite.draw AudioSprite.spec w)


slides opacity style_ ecs =
    let
        px =
            toFloat ecs.render.screen.width / ecs.render.virtualScreen.width

        style =
            style_ ++ [ VirtualDom.style "opacity" <| String.fromFloat opacity ]
    in
    [ List.map (\a -> a ecs.camera px) Content.all |> Slide.view style ]


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor (29 / 255) (33 / 255) (45 / 255) 1
    ]


objRender w ( _, objLayer ) =
    System.indexedFoldl3
        (\i _ c1 sprite acc ->
            acc
                |> (::)
                    (Sprite.draw
                        w.render
                        (case Logic.Entity.get i w.animation of
                            Just t ->
                                let
                                    testSprite =
                                        { sprite
                                            | uTileUV = TimeLine2.get w.frame t
                                            , uMirror = t.uMirror
                                        }
                                in
                                { testSprite
                                    | uP =
                                        c1
                                            |> AABB.getPosition
                                            |> (\{ x, y } -> { x = toFloat (round x), y = toFloat (round y) })
                                            |> Math.Vector2.fromRecord
                                }

                            Nothing ->
                                { sprite
                                    | uP =
                                        c1
                                            |> AABB.getPosition
                                            |> Math.Vector2.fromRecord
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
        target_ =
            getPosById w.camera.id w

        target =
            target_ |> (\a -> Vec2.sub a (getCenter w))

        cameraStep =
            Logic.Template.Camera.PositionLocking.lock target

        newOffset =
            Math.Vector2.fromRecord w.camera.viewportOffset

        updatedWorld =
            { w | render = RenderInfo.setOffset newOffset w.render }

        moveJump =
            vec2 13 8

        inputSpec_ =
            Logic.Template.Input.toComps Logic.Template.Input.spec
    in
    updatedWorld
        |> Logic.Template.System.SlideStop.applyInput inputSpec_ aabb.spec
        --        |> Control.platformer moveJump Logic.Template.Input.spec aabb.spec AudioSprite.spec
        |> aabb.system
        |> TimelineChange.sideScroll TimeLineDict2.spec aabb.spec TimeLine2.spec
        |> Singleton.update Logic.Template.Camera.spec cameraStep
        |> (\m -> ( m, Cmd.none ))



--        |> (\m -> ( m, start () ))
--
--
--port start : () -> Cmd msg


aabb =
    let
        empty =
            Logic.Template.Component.Physics.empty
    in
    { spec = Logic.Template.Component.Physics.spec
    , empty = { empty | gravity = { x = 0, y = -0.5 } }
    , system = Logic.Template.Component.Physics.system Logic.Template.Component.Physics.spec
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
    , y = 0.1 / w.render.px --0.5 / w.render.px
    }
