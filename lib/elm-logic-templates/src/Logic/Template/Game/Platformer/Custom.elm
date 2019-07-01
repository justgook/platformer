module Logic.Template.Game.Platformer.Custom exposing (PlatformerWorldWith, PlatformerWorldWith_)

import AltMath.Vector2 as Vec2 exposing (vec2)
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
import Logic.Template.Input
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)


type alias PlatformerWorldWith_ a =
    Launcher.World
        { a
            | camera : Logic.Template.Camera.WithId (Trigger {})
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
        }


type alias PlatformerWorldWith a =
    PlatformerWorldWith_ { custom : a }


emptyWith : a -> PlatformerWorldWith a
emptyWith a =
    let
        physicsEmpty =
            Logic.Template.Component.Physics.empty
    in
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running

    --    , flow = Flow.SlowMotion { frames = 160, fps = 1 }
    , camera = { viewportOffset = vec2 0 200, id = 0, yTarget = -1 }
    , sprites = Sprite.empty
    , input = Logic.Template.Input.empty
    , physics = { physicsEmpty | gravity = { x = 0, y = -0.5 } }
    , projectile = Projectile.empty
    , render = RenderInfo.empty
    , onScreen = OnScreenControl.emptyTwoButtonStick
    , animation = TimeLine.empty
    , animations = AnimationsDict.empty
    , layers = Logic.Template.Component.Layer.empty
    , sfx = Logic.Template.Component.SFX.empty
    , custom = a
    }
