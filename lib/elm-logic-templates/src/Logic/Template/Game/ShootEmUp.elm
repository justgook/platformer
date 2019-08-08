module Logic.Template.Game.ShootEmUp exposing (World, decode, encode, game, load, setInitResize)

--https://www.gamedev.net/articles/visual-arts/the-total-beginner%E2%80%99s-guide-to-better-2d-game-art-r2959/
--https://www.shadertoy.com/view/XlfGRj
--https://yahiko.developpez.com/apps/Starfield/

import AltMath.Vector2 as Vec2
import Browser.Dom as Browser
import Browser.Events as Events
import Bytes exposing (Bytes)
import Bytes.Encode exposing (Encoder)
import Html exposing (div, text)
import Html.Attributes exposing (style)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.GameFlow as Flow exposing (GameFlow(..))
import Logic.Launcher as Launcher
import Logic.System as System
import Logic.Template.Component.AI as AI exposing (AiPercentage)
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.Component.Animation as Animation exposing (Animation)
import Logic.Template.Component.AnimationsDict as AnimationsDict exposing (TimeLineDict3)
import Logic.Template.Component.Damage as Damage exposing (Damage)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.Component.FX as FX exposing (FX)
import Logic.Template.Component.HitPoints as HitPoints exposing (HitPoints)
import Logic.Template.Component.Hurt as Hurt exposing (HurtBox(..), HurtWorld)
import Logic.Template.Component.IdSource as IdSource exposing (IdSource)
import Logic.Template.Component.Lifetime as Lifetime exposing (Lifetime)
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Position as Position exposing (Position)
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Component.Velocity as Velocity exposing (Velocity)
import Logic.Template.GFX.Space
import Logic.Template.Game.ShootEmUp.Spawn as SelfEvent
import Logic.Template.Input as Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Internal exposing (fullscreenVertexShader)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Ammo as Ammo
import Logic.Template.SaveLoad.Animation as Animation
import Logic.Template.SaveLoad.AnimationsDict as AnimationsDict
import Logic.Template.SaveLoad.Hurt as Hurt
import Logic.Template.SaveLoad.Input as Input
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (WorldReader)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture, WorldDecoder, withTexture)
import Logic.Template.SaveLoad.Position as Position
import Logic.Template.SaveLoad.Sprite as Sprite
import Logic.Template.Sprite exposing (invertFragmentShader, mainFragmentShader)
import Logic.Template.System.AI as AI
import Logic.Template.System.Control as Control
import Logic.Template.System.CountDown
import Logic.Template.System.Fire
import Logic.Template.System.TimelineChange as TimelineChange
import Logic.Template.System.VelocityPosition
import Math.Vector2
import Random
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
        , sprites : Component.Set Sprite
        , input : Input.InputSingleton
        , position : Component.Set Position
        , hurt : HurtWorld
        , ammo : Component.Set Ammo
        , idSource : IdSource
        , onScreen : TwoButtonStick {}
        , animation : Component.Set Animation
        , animations : Component.Set (TimeLineDict3 Animation)
        , velocity : Component.Set Velocity
        , lifetime : Component.Set Lifetime
        , events : EventSequence SelfEvent.Event
        , ai2 : Component.Set AiPercentage
        , fx : FX
        , deadFx : Component.Set ( Animation, Sprite )
        , seed : Random.Seed
        , score : Int
        , hp : Component.Set HitPoints
        , damage : Component.Set Damage
        }


empty : ShootEmUpWorld
empty =
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , render = RenderInfo.empty

    --    , layers = Logic.Template.Component.Layer.empty
    , sprites = Sprite.empty
    , input = Input.empty
    , position = Position.empty
    , hurt = Hurt.empty
    , ammo = Ammo.empty
    , idSource = IdSource.empty 15
    , onScreen = OnScreenControl.emptyTwoButtonStick
    , animation = Animation.empty
    , animations = AnimationsDict.empty
    , velocity = Velocity.empty
    , lifetime = Lifetime.empty
    , events = EventSequence.empty
    , ai2 = AI.empty
    , fx = FX.empty
    , deadFx = Component.empty
    , seed = Random.initialSeed 42
    , score = 0
    , hp = HitPoints.empty
    , damage = Damage.empty
    }


clearOut id world =
    let
        remove =
            Entity.removeFor Position.spec
                >> Entity.removeFor Animation.spec
                >> Entity.removeFor AnimationsDict.spec
                >> Entity.removeFor Velocity.spec
                >> Entity.removeFor Lifetime.spec
                >> Entity.removeFor Sprite.spec
                >> Entity.removeFor AI.spec
                >> Entity.removeFor (Input.toComps Input.spec)
                >> Entity.removeFor Ammo.spec
                >> Entity.removeFor HitPoints.spec
                >> Entity.removeFor Damage.spec
                >> Entity.removeFor deadFxSpec
                >> Hurt.remove Hurt.spec
    in
    ( id, world |> Singleton.update IdSource.spec (\c -> { c | pool = id :: c.pool }) )
        |> remove
        |> Tuple.second


deadFxSpec : Component.Spec ( Animation, Sprite ) { world | deadFx : Component.Set ( Animation, Sprite ) }
deadFxSpec =
    { get = .deadFx
    , set = \comps world -> { world | deadFx = comps }
    }


lazyGetScale w =
    let
        { virtualScreen } =
            w.render
    in
    { x = virtualScreen.width, y = virtualScreen.height }


update world =
    world
        |> EventSequence.apply EventSequence.spec (SelfEvent.spawn deadFxSpec)
        |> AI.system lazyGetScale (Input.toComps Input.spec) Position.spec Velocity.spec AI.spec
        |> Control.shootEmUp { x = 10, y = 10 } Input.spec Position.spec world.render.virtualScreen
        |> Logic.Template.System.CountDown.system clearOut Lifetime.spec
        |> Logic.Template.System.VelocityPosition.system Velocity.spec Position.spec
        |> Logic.Template.System.Fire.spawn IdSource.spec Damage.spec Hurt.spec Input.spec Ammo.spec Position.spec Velocity.spec Lifetime.spec Sprite.spec
        |> TimelineChange.topDown (Input.toComps Input.spec) AnimationsDict.spec Animation.spec
        |> FX.system FX.spec
        |> (\w_ ->
                let
                    newWorld =
                        Hurt.collide onPlayerHit onEnemyHit_ ( Hurt.spec.get w_, Position.spec.get w_ ) w_
                in
                ( newWorld, Cmd.none )
           )


onEnemyHit_ i1 i2 acc =
    case
        Maybe.map2 (\damage hp -> hp - damage)
            (Entity.get i2 acc.damage)
            (Entity.get i1 acc.hp)
    of
        Just hpLeft ->
            if hpLeft <= 0 then
                onEnemyKill i1 acc
                    |> (\www ->
                            Entity.with ( Lifetime.spec, 1 ) ( i2, www )
                                |> Hurt.remove Hurt.spec
                                |> Tuple.second
                       )

            else
                { acc | hp = Component.set i1 hpLeft acc.hp }
                    |> FX.invertColors FX.spec i1
                    |> (\www ->
                            Entity.with ( Lifetime.spec, calculateRestLife i1 i2 acc ) ( i2, www )
                                |> Hurt.remove Hurt.spec
                                |> Tuple.second
                       )

        Nothing ->
            acc


calculateRestLife i1 i2 world =
    Position.spec.get world
        |> (\store ->
                Maybe.map3
                    (\p1 p2 v2 ->
                        Vec2.sub p1 p2
                            |> Vec2.length
                            |> (\a -> a / Vec2.length v2)
                            |> round
                    )
                    (Entity.get i1 store)
                    (Entity.get i2 store)
                    (Velocity.spec.get world |> Entity.get i2)
           )
        |> Maybe.withDefault 1


onPlayerHit pId i2 acc =
    clearOut i2 acc
        |> FX.shake FX.spec


onEnemyKill entityId world =
    let
        spawnExplosion anim sprite =
            --            Entity.removeFor Position.spec
            Entity.with ( Animation.spec, anim )
                >> Entity.removeFor AnimationsDict.spec
                >> Entity.with ( Velocity.spec, { x = 0, y = -3 } )
                >> Entity.with ( Lifetime.spec, 35 )
                >> Entity.with ( Sprite.spec, sprite )
                >> Entity.removeFor AI.spec
                >> Entity.removeFor (Input.toComps Input.spec)
                >> Entity.removeFor Ammo.spec
                >> Entity.removeFor HitPoints.spec
                >> Entity.removeFor Damage.spec
                >> Entity.removeFor deadFxSpec
                >> Hurt.remove Hurt.spec

        ( _, newWorld ) =
            case Entity.get entityId (deadFxSpec.get world) of
                Just ( anim, sprite ) ->
                    spawnExplosion anim sprite ( entityId, world )

                Nothing ->
                    ( entityId, clearOut entityId world )
    in
    { newWorld | score = newWorld.score + 10 }


view w_ =
    let
        ( w, renders ) =
            FX.draw FX.spec w_

        xOffset =
            w.render.offset
                |> Math.Vector2.getX

        space =
            Logic.Template.GFX.Space.draw fullscreenVertexShader
                { viewport = w.render.fixed
                , px = w.render.px
                , offset = Math.Vector2.vec2 (xOffset * 0.1) (w.runtime_ / 20)
                , time = toFloat w.frame
                }

        debug =
            Hurt.debug Hurt.spec Position.spec { uAbsolute = w.render.absolute, px = w.render.px } w

        playerEntityID =
            0
    in
    [ objRender w
        ++ debug
        --        |> (::) space
        |> WebGL.toHtmlWith webGLOption (RenderInfo.canvas w.render)
    , OnScreenControl.twoButtonStick
        (OnScreenControl.onscreenSpecExtend ""
            "Fire"
            OnScreenControl.spec
            (Input.toComps Input.spec)
            playerEntityID
        )
        w
    , score w
    ]


score world =
    div
        [ style "color" "white"
        , style "position" "absolute"
        , style "top" "1em"
        , style "left" "1em"
        ]
        [ text (String.fromInt world.score) ]


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor (29 / 255) (33 / 255) (45 / 255) 1
    ]


ifElse bool ifValue elseValue =
    if bool then
        ifValue

    else
        elseValue


objRender w =
    System.indexedFoldl2
        (\i sprite position ->
            let
                useInvert =
                    FX.get FX.spec i w
                        |> Maybe.map (\_ -> True)
                        |> Maybe.withDefault False
            in
            (::)
                (Sprite.drawCustom (ifElse useInvert invertFragmentShader mainFragmentShader)
                    w.render
                    (case Entity.get i w.animation of
                        Just t ->
                            let
                                testSprite =
                                    { sprite | uTileUV = Animation.get w.frame t, uMirror = t.uMirror }
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
        [ Keyboard.sub Input.spec w
        , Events.onResize (RenderInfo.resizeAndCenterLevelX RenderInfo.spec w)
        ]


read : List (WorldReader ShootEmUpWorld)
read =
    let
        ifPlayer =
            Reader.guard Input.haveInput
    in
    [ Sprite.read Sprite.spec |> ifPlayer
    , Animation.read Animation.spec |> ifPlayer
    , AnimationsDict.read Animation.fromTileset AnimationsDict.spec |> ifPlayer
    , Ammo.read Ammo.spec |> ifPlayer
    , Hurt.readPlayerHurt Hurt.spec |> ifPlayer
    , Position.read Position.spec |> ifPlayer
    , Input.read Input.spec
    , RenderInfo.read RenderInfo.spec

    ---------
    , SelfEvent.read EventSequence.spec
    ]


encoders : List (ShootEmUpWorld -> Encoder)
encoders =
    [ Sprite.encode Sprite.spec
    , Animation.encode Animation.spec
    , AnimationsDict.encode Animation.encodeItem AnimationsDict.spec
    , Ammo.encode Ammo.spec
    , Hurt.encode Hurt.spec
    , Position.encode Position.spec
    , RenderInfo.encode RenderInfo.spec
    , Input.encode Input.spec
    ]


decoders : GetTexture -> List (WorldDecoder ShootEmUpWorld)
decoders getTexture =
    [ Sprite.decode Sprite.spec |> withTexture getTexture
    , Animation.decode Animation.spec
    , AnimationsDict.decode Animation.decodeItem AnimationsDict.spec
    , Ammo.decode Ammo.spec |> withTexture getTexture
    , Hurt.decode Hurt.spec
    , Position.decode Position.spec
    , Input.decode Input.spec
    , RenderInfo.decode RenderInfo.spec
    ]


setInitResize =
    Task.map2
        (\{ scene } w ->
            RenderInfo.resizeAndCenterLevelX RenderInfo.spec w (round scene.width) (round scene.height)
        )
        Browser.getViewport
