module Logic.Template.Game.ShootEmUp exposing (World, game, load)

--https://www.gamedev.net/articles/visual-arts/the-total-beginner%E2%80%99s-guide-to-better-2d-game-art-r2959/
--https://www.shadertoy.com/view/XlfGRj
--https://yahiko.developpez.com/apps/Starfield/

import Browser.Dom as Browser
import Browser.Events as Events
import Bytes exposing (Bytes)
import Bytes.Encode exposing (Encoder)
import Logic.Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.GameFlow as Flow
import Logic.Launcher as Launcher
import Logic.System as System
import Logic.Template.Component.AI as AI exposing (AI)
import Logic.Template.Component.Ammo
import Logic.Template.Component.AnimationsDict as AnimationsDict exposing (TimeLineDict3)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.Component.FrameChange as FrameChange
import Logic.Template.Component.IdSource as IdSource exposing (IdSource)
import Logic.Template.Component.Lifetime as Lifetime exposing (Lifetime)
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Position as Position exposing (Position)
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Component.Velocity as Velocity exposing (Velocity)
import Logic.Template.GFX.Space
import Logic.Template.Game.ShootEmUp.Event as SelfEvent
import Logic.Template.Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Internal exposing (fullscreenVertexShader)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Ammo
import Logic.Template.SaveLoad.AnimationsDict as AnimationsDict
import Logic.Template.SaveLoad.FrameChange as FrameChange
import Logic.Template.SaveLoad.Input
import Logic.Template.SaveLoad.Internal.Reader exposing (Reader)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture, WorldDecoder, withTexture)
import Logic.Template.SaveLoad.Position
import Logic.Template.SaveLoad.Sprite as Sprite
import Logic.Template.System.AI as AI
import Logic.Template.System.Control as Control
import Logic.Template.System.CountDown
import Logic.Template.System.Fire
import Logic.Template.System.TimelineChange as TimelineChange
import Logic.Template.System.VelocityPosition
import Math.Vector2
import Task exposing (Task)
import WebGL


type alias World =
    ShootEmUpWorld


game : Launcher.Document flags ShootEmUpWorld
game =
    { update = update
    , view = view
    , subscriptions = subscriptions
    , init = \_ -> load "default.json"
    }


load : String -> Task Launcher.Error (Launcher.World ShootEmUpWorld)
load levelUrl =
    let
        worldTask =
            SaveLoad.loadTiled levelUrl empty read
    in
    setInitResize worldTask


encode : String -> Task.Task Launcher.Error ( Bytes, ShootEmUpWorld )
encode levelUrl =
    SaveLoad.loadTiledAndEncode levelUrl empty read encoders (\_ a -> a)
        |> ResourceTask.toTask


decode : Bytes -> Task Launcher.Error (Launcher.World ShootEmUpWorld)
decode bytes =
    let
        worldTask =
            SaveLoad.loadFromBytes bytes empty decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


run : String -> Task Launcher.Error (Launcher.World ShootEmUpWorld)
run levelUrl =
    let
        worldTask =
            SaveLoad.loadBytes levelUrl empty decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


type alias ShootEmUpWorld =
    Launcher.World
        { render : RenderInfo

        --        , layers : List Logic.Template.Component.Layer.Layer
        , sprites : Logic.Component.Set Sprite
        , input : Logic.Template.Input.InputSingleton
        , position : Logic.Component.Set Position
        , ammo : Logic.Component.Set Logic.Template.Component.Ammo.Ammo
        , idSource : IdSource
        , onScreen : TwoButtonStick {}
        , animation : Logic.Component.Set FrameChange.NotSimple
        , animations : Logic.Component.Set (TimeLineDict3 FrameChange.NotSimple)
        , velocity : Logic.Component.Set Velocity
        , lifetime : Logic.Component.Set Lifetime
        , events : EventSequence SelfEvent.Event
        , ai : Logic.Component.Set AI
        }


empty : ShootEmUpWorld
empty =
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , render = RenderInfo.empty

    --    , layers = Logic.Template.Component.Layer.empty
    , sprites = Sprite.empty
    , input = Logic.Template.Input.empty
    , position = Position.empty
    , ammo = Logic.Template.Component.Ammo.empty
    , idSource = IdSource.empty 5
    , onScreen = OnScreenControl.emptyTwoButtonStick
    , animation = FrameChange.empty
    , animations = AnimationsDict.empty
    , velocity = Velocity.empty
    , lifetime = Lifetime.empty
    , events = EventSequence.empty
    , ai = AI.empty
    }


onDead id world =
    let
        remove =
            Entity.removeFor Position.spec
                >> Entity.removeFor Velocity.spec
                >> Entity.removeFor Lifetime.spec
                >> Entity.removeFor Sprite.spec
                >> Entity.removeFor AI.spec
                >> Entity.removeFor (Logic.Template.Input.toComps Logic.Template.Input.spec)
                >> Entity.removeFor Logic.Template.Component.Ammo.spec
    in
    ( id, world |> Singleton.update IdSource.spec (\c -> { c | pool = id :: c.pool }) )
        |> remove
        |> Tuple.second


update w =
    w
        |> EventSequence.apply EventSequence.spec SelfEvent.spawn
        |> AI.system w.render AI.spec Position.spec
        |> Control.shootEmUp Logic.Template.Input.spec Position.spec
        |> Logic.Template.System.CountDown.system onDead Lifetime.spec
        |> Logic.Template.System.VelocityPosition.system Velocity.spec Position.spec
        |> Logic.Template.System.Fire.spawn IdSource.spec Logic.Template.Input.spec Logic.Template.Component.Ammo.spec Position.spec Velocity.spec Lifetime.spec Sprite.spec
        |> TimelineChange.topDown (Logic.Template.Input.toComps Logic.Template.Input.spec) AnimationsDict.spec FrameChange.spec
        |> (\m -> ( m, Cmd.none ))


view w =
    let
        space =
            Logic.Template.GFX.Space.draw fullscreenVertexShader
                { viewport = w.render.fixed
                , px = w.render.px
                , offset = Math.Vector2.vec2 0 (w.runtime_ / 20)
                , time = toFloat w.frame
                }

        playerEntityID =
            0
    in
    [ objRender w
        |> (::) space
        |> WebGL.toHtmlWith webGLOption (RenderInfo.canvas w.render)
    , OnScreenControl.twoButtonStick
        (OnScreenControl.onscreenSpecExtend
            OnScreenControl.spec
            (Logic.Template.Input.toComps Logic.Template.Input.spec)
            playerEntityID
        )
        w
    ]


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor (29 / 255) (33 / 255) (45 / 255) 1
    ]


objRender w =
    System.indexedFoldl2
        (\i sprite position ->
            (::)
                (Sprite.draw w.render
                    (case Entity.getComponent i w.animation of
                        Just t ->
                            let
                                testSprite =
                                    { sprite
                                        | uTileUV = FrameChange.get w.frame t
                                        , uMirror = t.uMirror
                                    }
                            in
                            { testSprite
                                | uP =
                                    position
                                        |> (\{ x, y } -> { x = toFloat (round x), y = toFloat (round y) })
                                        |> Math.Vector2.fromRecord
                            }

                        Nothing ->
                            { sprite
                                | uP =
                                    position
                                        |> (\{ x, y } -> { x = toFloat (round x), y = toFloat (round y) })
                                        |> Math.Vector2.fromRecord
                            }
                    )
                )
        )
        w.sprites
        w.position
        []


subscriptions w =
    Sub.batch
        [ Keyboard.sub Logic.Template.Input.spec w
        , Events.onResize (RenderInfo.resize RenderInfo.spec w)
        ]


read : List (Reader ShootEmUpWorld)
read =
    [ Sprite.read Sprite.spec
    , RenderInfo.read RenderInfo.spec
    , Logic.Template.SaveLoad.Input.read Logic.Template.Input.spec
    , Logic.Template.SaveLoad.Position.read Position.spec

    ---------
    , Logic.Template.SaveLoad.Ammo.read Logic.Template.Component.Ammo.spec
    , FrameChange.read FrameChange.spec
    , AnimationsDict.read FrameChange.fromTileset AnimationsDict.spec
    , SelfEvent.read EventSequence.spec
    ]


encoders : List (ShootEmUpWorld -> Encoder)
encoders =
    [ Sprite.encode Sprite.spec
    , RenderInfo.encode RenderInfo.spec
    , Logic.Template.SaveLoad.Input.encode Logic.Template.Input.spec
    , Logic.Template.SaveLoad.Position.encode Position.spec
    ]


decoders : GetTexture -> List (WorldDecoder ShootEmUpWorld)
decoders getTexture =
    [ Sprite.decode Sprite.spec |> withTexture getTexture
    , RenderInfo.decode RenderInfo.spec
    , Logic.Template.SaveLoad.Input.decode Logic.Template.Input.spec
    , Logic.Template.SaveLoad.Position.decode Position.spec
    ]


setInitResize =
    Task.map2
        (\{ scene } w ->
            RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
        )
        Browser.getViewport
