module Logic.Template.Game.TopDown exposing (World, decode, decoders, empty, encode, encoders, game, load, read, run, setInitResize)

import Browser.Events as Events
import Bytes exposing (Bytes)
import Bytes.Encode exposing (Encoder)
import Logic.Component as Component
import Logic.Entity as Entity
import Logic.GameFlow exposing (GameFlow(..))
import Logic.Launcher as Launcher
import Logic.System as System
import Logic.Template.Component.Animation as Animation exposing (Animation)
import Logic.Template.Component.AnimationsDict as AnimationsDict exposing (TimeLineDict3)
import Logic.Template.Component.Layer
import Logic.Template.Component.Position as Position exposing (Position)
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Component.Velocity as Velocity exposing (Velocity)
import Logic.Template.Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Animation as Animation
import Logic.Template.SaveLoad.AnimationsDict as AnimationsDict
import Logic.Template.SaveLoad.Input
import Logic.Template.SaveLoad.Internal.Reader exposing (WorldReader)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture, WorldDecoder, withTexture)
import Logic.Template.SaveLoad.Layer exposing (lutCollector)
import Logic.Template.SaveLoad.Position
import Logic.Template.SaveLoad.Sprite as Sprite
import Logic.Template.Sprite exposing (mainFragmentShader)
import Logic.Template.System.Control as Control
import Logic.Template.System.TimelineChange as TimelineChange
import Logic.Template.System.VelocityPosition
import Math.Vector2
import Task exposing (Task)
import WebGL



--https://sanderfrenken.github.io/Universal-LPC-Spritesheet-Character-Generator/
--http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/
--https://web.archive.org/web/20141219071009/http://www.famitsu.com/freegame/tool/chibi/index1.html


type alias World =
    { render : RenderInfo
    , frame : Int
    , runtime_ : Float
    , flow : GameFlow
    , layers : List Logic.Template.Component.Layer.Layer
    , input : Logic.Template.Input.InputSingleton
    , sprites : Component.Set Sprite
    , animation : Component.Set Animation
    , animations : Component.Set (TimeLineDict3 Animation)
    , position : Component.Set Position
    , velocity : Component.Set Velocity
    }


empty : World
empty =
    { render = RenderInfo.empty
    , frame = 0
    , runtime_ = 0
    , flow = Running
    , layers = Logic.Template.Component.Layer.empty
    , input = Logic.Template.Input.empty
    , sprites = Sprite.empty
    , animation = Animation.empty
    , animations = AnimationsDict.empty
    , position = Position.empty
    , velocity = Velocity.empty
    }


game : Launcher.Document flags World
game =
    { update = update
    , view = view
    , subscriptions = subscriptions
    , init = \_ -> load "default.json"
    }


view w =
    [ Logic.Template.Component.Layer.draw (objRender w) w
        |> WebGL.toHtmlWith webGLOption (RenderInfo.canvas w.render)
    ]


objRender w ( _, objLayer ) =
    System.indexedFoldl3
        (\i sprite position _ ->
            (::)
                (Sprite.drawCustom mainFragmentShader
                    w.render
                    (case Entity.get i w.animation of
                        Just t ->
                            let
                                animationFrame =
                                    { sprite | uTileUV = Animation.get w.frame t, uMirror = t.uMirror }
                            in
                            { animationFrame
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
        objLayer
        []


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor (29 / 255) (33 / 255) (45 / 255) 1
    ]


update w =
    ( w
        |> Logic.Template.System.VelocityPosition.system Velocity.spec Position.spec
        |> Control.shootEmUp { x = 3, y = 3 } Logic.Template.Input.spec Position.spec w.render.virtualScreen
        |> TimelineChange.topDown (Logic.Template.Input.toComps Logic.Template.Input.spec) AnimationsDict.spec Animation.spec
    , Cmd.none
    )


load : String -> Task Launcher.Error (Launcher.World World)
load levelUrl =
    SaveLoad.loadTiled levelUrl empty read
        |> RenderInfo.setInitResize RenderInfo.spec


encode : String -> Task.Task Launcher.Error ( Bytes, World )
encode levelUrl =
    SaveLoad.loadTiledAndEncode levelUrl empty read encoders lutCollector
        |> ResourceTask.toTask


decode : Bytes -> Task Launcher.Error (Launcher.World World)
decode bytes =
    SaveLoad.loadFromBytes bytes empty decoders
        |> ResourceTask.toTask
        |> RenderInfo.setInitResize RenderInfo.spec


run : String -> Task Launcher.Error (Launcher.World World)
run levelUrl =
    let
        worldTask =
            SaveLoad.loadBytes levelUrl empty decoders |> ResourceTask.toTask
    in
    RenderInfo.setInitResize RenderInfo.spec worldTask


subscriptions : World -> Sub World
subscriptions w =
    Sub.batch
        [ Keyboard.sub Logic.Template.Input.spec w
        , Events.onResize (RenderInfo.resize RenderInfo.spec w)
        ]


read : List (WorldReader World)
read =
    [ Logic.Template.SaveLoad.Layer.read Logic.Template.Component.Layer.spec
    , Logic.Template.SaveLoad.Input.read Logic.Template.Input.spec
    , RenderInfo.read RenderInfo.spec
    , Sprite.read Sprite.spec
    , Animation.read Animation.spec
    , Logic.Template.SaveLoad.Position.read Position.spec
    , AnimationsDict.read Animation.fromTileset AnimationsDict.spec
    ]


encoders : List (World -> Encoder)
encoders =
    [ Sprite.encode Sprite.spec
    , Logic.Template.SaveLoad.Input.encode Logic.Template.Input.spec
    , RenderInfo.encode RenderInfo.spec
    , Animation.encode Animation.spec
    , Logic.Template.SaveLoad.Position.encode Position.spec
    , AnimationsDict.encode Animation.encodeItem AnimationsDict.spec
    , Logic.Template.SaveLoad.Layer.encode Logic.Template.Component.Layer.spec
    ]


decoders : GetTexture -> List (WorldDecoder World)
decoders getTexture =
    [ Sprite.decode Sprite.spec |> withTexture getTexture
    , Logic.Template.SaveLoad.Input.decode Logic.Template.Input.spec
    , RenderInfo.decode RenderInfo.spec
    , Animation.decode Animation.spec
    , Logic.Template.SaveLoad.Position.decode Position.spec
    , AnimationsDict.decode Animation.decodeItem AnimationsDict.spec
    , Logic.Template.SaveLoad.Layer.decode Logic.Template.Component.Layer.spec |> withTexture getTexture
    ]


setInitResize : Task x World -> Task x World
setInitResize =
    RenderInfo.setInitResize RenderInfo.spec
