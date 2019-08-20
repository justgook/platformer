module Logic.Template.Game.Platformer.Common exposing (PlatformerWorld, decoders, empty, encoders, read)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Bytes.Encode as E exposing (Encoder)
import Logic.GameFlow as Flow
import Logic.Template.Camera
import Logic.Template.Component.Animation as TimeLine
import Logic.Template.Component.AnimationsDict as AnimationsDict exposing (TimeLineDict3)
import Logic.Template.Component.Layer
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Physics
import Logic.Template.Component.SFX
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.GFX.Projectile as Projectile exposing (Projectile)
import Logic.Template.Game.Platformer.Custom exposing (PlatformerWorldWith_)
import Logic.Template.Input
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad.Animation as TimeLine
import Logic.Template.SaveLoad.AnimationsDict as AnimationsDict
import Logic.Template.SaveLoad.AudioSprite
import Logic.Template.SaveLoad.Camera
import Logic.Template.SaveLoad.Input
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (WorldReader)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture, WorldDecoder, withTexture)
import Logic.Template.SaveLoad.Layer
import Logic.Template.SaveLoad.Physics
import Logic.Template.SaveLoad.Sprite as Sprite


type alias PlatformerWorld =
    PlatformerWorldWith_ {}


empty : PlatformerWorld
empty =
    let
        physics =
            Logic.Template.Component.Physics.empty

        audiosprite =
            Logic.Template.Component.SFX.empty
    in
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running

    --    , flow = Flow.SlowMotion { frames = 160, fps = 1 }
    , camera = { viewportOffset = vec2 0 200, id = 0, yTarget = -1 }
    , sprites = Sprite.empty
    , input = Logic.Template.Input.empty
    , physics = { physics | gravity = { x = 0, y = -0.5 } }
    , projectile = Projectile.empty
    , render = RenderInfo.empty
    , onScreen = OnScreenControl.emptyTwoButtonStick
    , animation = TimeLine.empty
    , animations = AnimationsDict.empty
    , layers = Logic.Template.Component.Layer.empty
    , sfx = audiosprite
    }


encoders : List (PlatformerWorld -> Encoder)
encoders =
    [ Sprite.encode Sprite.spec
    , Logic.Template.SaveLoad.Input.encode Logic.Template.Input.spec
    , TimeLine.encode TimeLine.spec
    , AnimationsDict.encode TimeLine.encodeItem AnimationsDict.spec
    , RenderInfo.encode RenderInfo.spec
    , Logic.Template.SaveLoad.Layer.encode Logic.Template.Component.Layer.spec
    , Logic.Template.SaveLoad.Physics.encode Logic.Template.Component.Physics.spec
    , Logic.Template.SaveLoad.Camera.encode Logic.Template.Camera.spec
    , Logic.Template.SaveLoad.AudioSprite.encode Logic.Template.Component.SFX.spec
    ]


decoders : GetTexture -> List (WorldDecoder PlatformerWorld)
decoders getTexture =
    [ Sprite.decode Sprite.spec |> withTexture getTexture
    , Logic.Template.SaveLoad.Input.decode Logic.Template.Input.spec
    , TimeLine.decode TimeLine.spec
    , AnimationsDict.decode TimeLine.decodeItem AnimationsDict.spec
    , RenderInfo.decode RenderInfo.spec
    , Logic.Template.SaveLoad.Layer.decode Logic.Template.Component.Layer.spec |> withTexture getTexture
    , Logic.Template.SaveLoad.Physics.decode Logic.Template.Component.Physics.spec
    , Logic.Template.SaveLoad.Camera.decode Logic.Template.Camera.spec
    , Logic.Template.SaveLoad.AudioSprite.decode Logic.Template.Component.SFX.spec
    ]


read : List (WorldReader PlatformerWorld)
read =
    [ Sprite.read Sprite.spec
    , Logic.Template.SaveLoad.Input.read Logic.Template.Input.spec
    , Logic.Template.SaveLoad.Camera.read Logic.Template.Camera.spec
    , RenderInfo.read RenderInfo.spec
    , Logic.Template.SaveLoad.Physics.read Logic.Template.Component.Physics.spec
    , TimeLine.read TimeLine.spec
    , AnimationsDict.read TimeLine.fromTileset AnimationsDict.spec
    , Logic.Template.SaveLoad.Layer.read Logic.Template.Component.Layer.spec
    , Logic.Template.SaveLoad.AudioSprite.read Logic.Template.Component.SFX.spec
    ]
