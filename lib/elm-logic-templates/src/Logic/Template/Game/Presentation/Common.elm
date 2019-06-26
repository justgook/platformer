module Logic.Template.Game.Presentation.Common exposing (PresentationWorld, decoders, empty, encoders, read)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Bytes.Encode as E exposing (Encoder)
import Collision.Physic.AABB as AABB
import Logic.Component
import Logic.GameFlow as Flow
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Camera
import Logic.Template.Camera.Trigger exposing (Trigger)
import Logic.Template.Component.AnimationsDict as AnimationsDict exposing (TimeLineDict3)
import Logic.Template.Component.FrameChange as TimeLine
import Logic.Template.Component.Layer
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Physics
import Logic.Template.Component.SFX
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.GFX.Projectile as Projectile exposing (Projectile)
import Logic.Template.Game.Presentation.Content2 as Content
import Logic.Template.Input
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad.AnimationsDict as AnimationsDict
import Logic.Template.SaveLoad.AudioSprite
import Logic.Template.SaveLoad.Camera
import Logic.Template.SaveLoad.FrameChange as TimeLine
import Logic.Template.SaveLoad.Input
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Reader)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture, WorldDecoder, withTexture)
import Logic.Template.SaveLoad.Layer
import Logic.Template.SaveLoad.Physics
import Logic.Template.SaveLoad.Sprite as Sprite


type alias PresentationWorld =
    Launcher.World
        { camera : Logic.Template.Camera.WithId (Trigger {})
        , sprites : Logic.Component.Set Sprite
        , physics : AABB.World Int
        , input : Logic.Template.Input.InputSingleton
        , projectile : Projectile
        , render : RenderInfo
        , onScreen : TwoButtonStick {}
        , animation : Logic.Component.Set TimeLine.NotSimple
        , animations : Logic.Component.Set (TimeLineDict3 TimeLine.NotSimple)
        , layers : List Logic.Template.Component.Layer.Layer
        , sfx : Logic.Template.Component.SFX.AudioSprite
        , slideStops : SlideStops
        , slideOpacity : Float
        }


type alias SlideStops =
    { prev : List Vec2
    , target : Vec2
    , next : List Vec2
    }


empty : PresentationWorld
empty =
    let
        physics =
            Logic.Template.Component.Physics.empty

        audiosprite =
            Logic.Template.Component.SFX.empty

        slidePos i =
            Content.dimension.x * 0.5 + Content.startPoint.x + (Content.dimension.x + Content.space) * toFloat i

        slideStopsNext =
            List.indexedMap (\i _ -> vec2 (slidePos i) 61) Content.all
    in
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , camera = { viewportOffset = vec2 0 200, id = 0, yTarget = -1 }
    , sprites = Sprite.empty
    , input = Logic.Template.Input.empty
    , physics = { physics | gravity = { x = 0, y = -1.5 } }
    , projectile = Projectile.empty
    , render = RenderInfo.empty
    , onScreen = OnScreenControl.emptyTwoButtonStick
    , animation = TimeLine.empty
    , animations = AnimationsDict.empty
    , layers = Logic.Template.Component.Layer.empty
    , sfx = audiosprite
    , slideStops =
        { prev = []
        , target = vec2 289 61
        , next = slideStopsNext
        }
    , slideOpacity = 1
    }


encoders : List (PresentationWorld -> Encoder)
encoders =
    [ Sprite.encode Sprite.spec
    , Logic.Template.SaveLoad.Input.encode Logic.Template.Input.spec
    , TimeLine.encode TimeLine.spec
    , AnimationsDict.encode TimeLine.encodeItem AnimationsDict.spec
    , RenderInfo.encode RenderInfo.spec
    , Logic.Template.SaveLoad.Layer.encode Logic.Template.Component.Layer.spec
    , Logic.Template.SaveLoad.Physics.encode Logic.Template.Component.Physics.spec
    , Logic.Template.SaveLoad.Camera.encodeId Logic.Template.Camera.spec
    , Logic.Template.SaveLoad.AudioSprite.encode Logic.Template.Component.SFX.spec
    ]


decoders : GetTexture -> List (WorldDecoder PresentationWorld)
decoders getTexture =
    [ Sprite.decode Sprite.spec |> withTexture getTexture
    , Logic.Template.SaveLoad.Input.decode Logic.Template.Input.spec
    , TimeLine.decode TimeLine.spec
    , AnimationsDict.decode TimeLine.decodeItem AnimationsDict.spec
    , RenderInfo.decode RenderInfo.spec
    , Logic.Template.SaveLoad.Layer.decode Logic.Template.Component.Layer.spec |> withTexture getTexture
    , Logic.Template.SaveLoad.Physics.decode Logic.Template.Component.Physics.spec
    , Logic.Template.SaveLoad.Camera.decodeId Logic.Template.Camera.spec
    , Logic.Template.SaveLoad.AudioSprite.decode Logic.Template.Component.SFX.spec
    ]


read : List (Reader PresentationWorld)
read =
    [ Sprite.read Sprite.spec
    , Logic.Template.SaveLoad.Input.read Logic.Template.Input.spec
    , Logic.Template.SaveLoad.Camera.readId Logic.Template.Camera.spec
    , RenderInfo.read RenderInfo.spec
    , Logic.Template.SaveLoad.Physics.read Logic.Template.Component.Physics.spec
    , TimeLine.read TimeLine.spec
    , AnimationsDict.read TimeLine.fromTileset AnimationsDict.spec
    , Logic.Template.SaveLoad.Layer.read Logic.Template.Component.Layer.spec
    , Logic.Template.SaveLoad.AudioSprite.read Logic.Template.Component.SFX.spec
    ]
