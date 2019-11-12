module Logic.Template.Game.ShootEmUp exposing (World, decode, encode, game, load, run, setInitResize)

--https://www.gamedev.net/articles/visual-arts/the-total-beginner%E2%80%99s-guide-to-better-2d-game-art-r2959/
--https://www.shadertoy.com/view/XlfGRj
--https://yahiko.developpez.com/apps/Starfield/
--https://raymond-schlitter.squarespace.com/blog/2017/9/18/thyria-devlog-06-one-year-and-going-strong

import AltMath.Vector2
import Browser.Dom as Browser
import Browser.Events as Events
import Bytes exposing (Bytes)
import Bytes.Decode as D
import Bytes.Encode exposing (Encoder)
import Html exposing (div, text)
import Html.Attributes exposing (style)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.GameFlow as Flow exposing (GameFlow(..))
import Logic.Launcher as Launcher
import Logic.System as System
import Logic.Template.Camera.PositionLocking
import Logic.Template.Component.AI as AI exposing (AiTargets)
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.Component.Animation as Animation exposing (Animation)
import Logic.Template.Component.AnimationsDict as AnimationsDict exposing (TimeLineDict3)
import Logic.Template.Component.Circles as Circles exposing (Circles)
import Logic.Template.Component.Damage as Damage exposing (Damage)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.Component.FX as FX exposing (FX)
import Logic.Template.Component.HitPoints as HitPoints exposing (HitPoints)
import Logic.Template.Component.IdSource as IdSource exposing (IdSource)
import Logic.Template.Component.Layer
import Logic.Template.Component.LevelSize as LevelSize exposing (LevelSize)
import Logic.Template.Component.Lifetime as Lifetime exposing (Lifetime)
import Logic.Template.Component.OnScreenControl as OnScreenControl exposing (TwoButtonStick)
import Logic.Template.Component.Position as Position exposing (Position)
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Component.Velocity as Velocity exposing (Velocity)
import Logic.Template.GFX.Space
import Logic.Template.Game.ShootEmUp.Objects as Objects exposing (OnContact(..), OnDeath(..))
import Logic.Template.Input as Input
import Logic.Template.Input.Keyboard as Keyboard
import Logic.Template.Internal exposing (fullscreenVertexShader, tileVertexShader)
import Logic.Template.Rectangle as Rectangle
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Ammo as Ammo
import Logic.Template.SaveLoad.Animation as Animation
import Logic.Template.SaveLoad.AnimationsDict as AnimationsDict
import Logic.Template.SaveLoad.Circles as Circles
import Logic.Template.SaveLoad.EventSequence as EventSequence
import Logic.Template.SaveLoad.Input as Input
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture, WorldDecoder, withTexture)
import Logic.Template.SaveLoad.Layer
import Logic.Template.SaveLoad.LevelSize as LevelSize
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
import Math.Vector4
import Random
import Set
import Task exposing (Task)
import WebGL


type alias World =
    Launcher.World ShootEmUpWorld


game : Launcher.Document flags World
game =
    { update = update
    , view = view
    , subscriptions = subscriptions
    , init = \_ -> load "default.json"
    }


load : String -> Task Launcher.Error World
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


decode : Bytes -> Task Launcher.Error World
decode bytes =
    let
        worldTask =
            SaveLoad.loadFromBytes bytes empty decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


run : String -> Task Launcher.Error World
run levelUrl =
    let
        worldTask =
            SaveLoad.loadBytes levelUrl empty decoders |> ResourceTask.toTask
    in
    setInitResize worldTask


type alias ShootEmUpWorld =
    Launcher.World
        { render : RenderInfo
        , levelSize : LevelSize
        , layers : List Logic.Template.Component.Layer.Layer

        --        , layers : List Logic.Template.Component.Layer.Layer
        , sprites : Component.Set Sprite
        , input : Input.InputSingleton
        , position : Component.Set Position
        , ammo : Component.Set Ammo
        , idSource : IdSource
        , onScreen : TwoButtonStick {}
        , animation : Component.Set Animation
        , animations : Component.Set (TimeLineDict3 Animation)
        , velocity : Component.Set Velocity
        , lifetime : Component.Set Lifetime
        , events2 : EventSequence Objects.Event
        , ai2 : Component.Set AiTargets
        , fx : FX
        , camera : EntityID

        --        ,cameraClamp: {xMin:Int, xMax: Int}
        --        , deadFx : Component.Set ( Animation, Sprite )
        , seed : Random.Seed
        , score : Int
        , hp : Component.Set HitPoints
        , damage : Component.Set Damage
        , onContact : Component.Set (List OnContact)
        , onDeath : Component.Set (List OnDeath)

        ---- NEW "physics"
        , playerHitBox : Component.Set Circles
        , enemyHitBox : Component.Set Circles
        , playerHurtBox : Component.Set Circles
        , enemyHurtBox : Component.Set Circles
        , rewardHurtBox : Component.Set Circles

        -- Particles
        --        , particles:
        }


empty : ShootEmUpWorld
empty =
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , render = RenderInfo.empty
    , levelSize = LevelSize.empty
    , layers = Logic.Template.Component.Layer.empty

    --    , layers = Logic.Template.Component.Layer.empty
    , sprites = Sprite.empty
    , input = Input.empty
    , position = Position.empty
    , ammo = Ammo.empty
    , idSource = IdSource.empty 1
    , onScreen = OnScreenControl.emptyTwoButtonStick
    , animation = Animation.empty
    , animations = AnimationsDict.empty
    , velocity = Velocity.empty
    , lifetime = Lifetime.empty
    , events2 = EventSequence.empty
    , ai2 = AI.empty
    , fx = FX.empty
    , camera = -1

    --    , deadFx = Component.empty
    , seed = Random.initialSeed 42
    , score = 0
    , hp = HitPoints.empty
    , damage = Damage.empty
    , onContact = Component.empty
    , onDeath = Component.empty

    ---- NEW "physics"
    , playerHitBox = Component.empty
    , enemyHitBox = Component.empty
    , playerHurtBox = Component.empty
    , enemyHurtBox = Component.empty
    , rewardHurtBox = Component.empty
    }



--removeEntity : EntityID -> World -> World


lazyGetScale w =
    let
        { virtualScreen } =
            w.render
    in
    { x = virtualScreen.width, y = virtualScreen.height }


update world =
    let
        cameraSystem =
            Logic.Template.Camera.PositionLocking.xClamp LevelSize.spec RenderInfo.spec
    in
    world
        |> EventSequence.apply eventSequenceSpec2 spawnEnemy2
        |> AI.system (Input.toComps Input.spec) Position.spec Velocity.spec AI.spec
        |> Control.shootEmUp (AltMath.Vector2.vec2 10 10) Input.spec Position.spec world.render.virtualScreen
        |> Logic.Template.System.CountDown.system removeEntity Lifetime.spec
        |> Logic.Template.System.VelocityPosition.system Velocity.spec Position.spec
        |> (\w_ -> System.applyMaybe (Entity.get w_.camera w_.position) cameraSystem w_)
        |> Logic.Template.System.Fire.system spawnBullet (Input.toComps Input.spec) Ammo.spec
        |> TimelineChange.topDown (Input.toComps Input.spec) AnimationsDict.spec Animation.spec
        |> FX.system FX.spec
        |> (\w_ ->
                let
                    newWorld =
                        w_
                            |> (\w__ -> Circles.collide onPlayerHit w__.position w__.playerHurtBox w__.enemyHurtBox w__)
                            |> (\w__ -> Circles.collide onPlayerHit w__.position w__.playerHurtBox w__.enemyHitBox w__)
                            |> (\w__ -> Circles.collide onEnemyHit w__.position w__.enemyHurtBox w__.playerHitBox w__)
                            |> (\w__ -> Circles.collide onRewardHit w__.position w__.playerHurtBox w__.rewardHurtBox w__)
                in
                newWorld
           )


spawnEnemy2 ({ targets } as item) world =
    let
        startPos =
            item.targets.target.position

        input =
            Input.emptyComp

        target =
            item.targets.target
    in
    IdSource.create IdSource.spec world
        |> Entity.with ( Sprite.spec, item.sprite )
        |> Entity.with ( Position.spec, startPos )
        |> Entity.with ( Velocity.spec, AltMath.Vector2.vec2 0 0 )
        |> Entity.with ( enemyHurtBoxSpec, item.hurtbox )
        |> Entity.with ( AI.spec, { targets | target = { target | position = startPos } } )
        |> Entity.with ( Ammo.spec, item.ammo )
        |> Entity.with ( HitPoints.spec, item.hp )
        |> Entity.with ( Input.toComps Input.spec, { input | action = Set.fromList item.targets.target.action } )
        |> Entity.with ( onDeathSpec, item.onDeath )
        |> maybeSpawn ( Lifetime.spec, item.lifetime )
        |> maybeSpawn ( Animation.spec, item.animation )
        |> Tuple.second


spawnBullet entityId template w =
    let
        lifetime =
            100

        hitBox : Circles
        hitBox =
            [ ( AltMath.Vector2.vec2 -10 10, 5 ) ]

        hitSpec =
            case Entity.get entityId w.enemyHurtBox of
                Just _ ->
                    enemyHitBoxSpec

                Nothing ->
                    playerHitBoxSpec
    in
    case Entity.get entityId w.position of
        Just pos ->
            w
                |> IdSource.create IdSource.spec
                |> Entity.with ( Position.spec, AltMath.Vector2.add pos template.offset )
                |> Entity.with ( Velocity.spec, .velocity template )
                |> Entity.with ( Lifetime.spec, lifetime )
                |> Entity.with ( Sprite.spec, template.sprite )
                |> Entity.with ( Damage.spec, template.damage )
                |> Entity.with ( hitSpec, hitBox )
                |> Tuple.second

        Nothing ->
            w


onEnemyHit i1 i2 acc =
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
                                |> Entity.removeFor playerHitBoxSpec
                                |> Tuple.second
                       )

            else
                { acc | hp = Component.set i1 hpLeft acc.hp }
                    |> FX.invertColors FX.spec i1
                    |> (\www ->
                            Entity.with ( Lifetime.spec, calculateRestLife i1 i2 acc ) ( i2, www )
                                |> Entity.removeFor playerHitBoxSpec
                                |> Tuple.second
                       )

        Nothing ->
            acc


calculateRestLife i1 i2 world =
    Position.spec.get world
        |> (\store ->
                Maybe.map3
                    (\p1 p2 v2 ->
                        AltMath.Vector2.sub p1 p2
                            |> AltMath.Vector2.length
                            |> (\a -> a / AltMath.Vector2.length v2)
                            |> round
                    )
                    (Entity.get i1 store)
                    (Entity.get i2 store)
                    (Velocity.spec.get world |> Entity.get i2)
           )
        |> Maybe.withDefault 1


onPlayerHit pId enemyId acc =
    removeEntity enemyId acc
        |> FX.shake FX.spec


onRewardHit pId enemyId acc =
    (case Entity.get enemyId acc.onContact of
        Just ((SetAmmo name) :: []) ->
            acc |> Singleton.update Ammo.spec (Entity.update pId (Ammo.set name))

        _ ->
            acc
    )
        |> removeEntity enemyId


onEnemyKill entityId world =
    let
        onDeath pos item w =
            IdSource.create IdSource.spec w
                |> (case item of
                        SpawnExplosion { anim, sprite, offset } ->
                            Entity.with ( Position.spec, AltMath.Vector2.add pos offset )
                                >> Entity.with ( Sprite.spec, sprite )
                                >> maybeSpawn ( Animation.spec, anim )
                                >> Entity.with ( Lifetime.spec, 100 )

                        SpawnReward { anim, sprite, offset, hurtbox, onContact } ->
                            Entity.with ( Position.spec, AltMath.Vector2.add pos offset )
                                >> Entity.with ( Sprite.spec, sprite )
                                >> maybeSpawn ( Animation.spec, anim )
                                >> Entity.with ( Lifetime.spec, 1000 )
                                >> Entity.with ( Velocity.spec, AltMath.Vector2.vec2 0 -1 )
                                >> Entity.with ( rewardHurtBoxSpec, hurtbox )
                                >> Entity.with ( onContactSpec, onContact )

                        _ ->
                            identity
                   )
                |> Tuple.second

        ( _, newWorld ) =
            case ( Entity.get entityId (Position.spec.get world), Entity.get entityId (onDeathSpec.get world) ) of
                ( Just pos, Just death ) ->
                    ( entityId, List.foldl (onDeath pos) (removeEntity entityId world) death )

                _ ->
                    ( entityId, removeEntity entityId world )
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

        --        debug2 =
        --            Circles.debug { r = 90 / 255, g = 1, b = 80 / 255 } w.playerHurtBox w.position { uAbsolute = w.render.absolute, px = w.render.px }
        --                ++ Circles.debug { r = 77 / 255, g = 0.5, b = 201 / 255 } w.enemyHurtBox w.position { uAbsolute = w.render.absolute, px = w.render.px }
        --                ++ Circles.debug { r = 233 / 255, g = 56 / 255, b = 65 / 255 } w.enemyHitBox w.position { uAbsolute = w.render.absolute, px = w.render.px }
        --                ++ Circles.debug { r = 1, g = 1, b = 1 } w.playerHitBox w.position { uAbsolute = w.render.absolute, px = w.render.px }
        --                ++ Circles.debug { r = 0, g = modBy 5 w_.frame |> toFloat, b = 1 } w.rewardHurtBox w.position { uAbsolute = w.render.absolute, px = w.render.px }
        playerEntityID =
            0
    in
    [ Logic.Template.Component.Layer.draw (always []) w
        ++ objRender w
        --        ++ debug2
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
                                animatedSprite =
                                    { sprite
                                        | uTileUV = Animation.get w.frame t
                                        , uMirror = t.uMirror
                                    }
                            in
                            { animatedSprite
                                | uP =
                                    position
                                        |> AltMath.Vector2.toRecord
                                        |> (\{ x, y } -> Math.Vector2.vec2 (toFloat (round x)) (toFloat (round y)))
                            }

                        Nothing ->
                            { sprite
                                | uP =
                                    position
                                        |> AltMath.Vector2.toRecord
                                        |> (\{ x, y } -> Math.Vector2.vec2 (toFloat (round x)) (toFloat (round y)))
                            }
                    )
                )
                |> (\l ->
                        case Entity.get i w.hp of
                            Just hp ->
                                let
                                    pxToScreen px p_ =
                                        p_
                                            |> AltMath.Vector2.add (AltMath.Vector2.vec2 0 -70)
                                            |> AltMath.Vector2.scale px
                                            |> AltMath.Vector2.toRecord
                                            |> Math.Vector2.fromRecord

                                    width =
                                        toFloat hp * 0.1

                                    h =
                                        10

                                    delme =
                                        { uDimension = Math.Vector2.vec2 (width * w.render.px) (h * w.render.px)
                                        , absolute = w.render.absolute
                                        , uAbsolute = w.render.absolute
                                        , uP = pxToScreen w.render.px position
                                        , color = Math.Vector4.vec4 0.8 0.2 0.2 1
                                        }
                                            |> inlineRectangleFill
                                in
                                (::) delme >> l

                            _ ->
                                l
                   )
        )
        w.sprites
        w.position
        []


inlineRectangleFill =
    Rectangle.fill tileVertexShader


subscriptions w =
    Sub.batch
        [ Keyboard.sub Input.spec w
        , Events.onResize (RenderInfo.resize RenderInfo.spec w)
        ]


read : List (WorldReader ShootEmUpWorld)
read =
    let
        ifPlayer =
            Reader.guard Input.haveInput

        cameraRead : WorldReader ShootEmUpWorld
        cameraRead =
            { defaultRead | objectTile = Sync (\_ ( entityID, world ) -> ( entityID, { world | camera = entityID } )) } |> ifPlayer
    in
    [ Logic.Template.SaveLoad.Layer.read Logic.Template.Component.Layer.spec
    , Sprite.read Sprite.spec |> ifPlayer
    , Animation.read Animation.spec |> ifPlayer
    , AnimationsDict.read Animation.fromTileset AnimationsDict.spec |> ifPlayer
    , Ammo.read Ammo.spec |> ifPlayer
    , Position.read Position.spec |> ifPlayer
    , cameraRead
    , Input.read Input.spec
    , RenderInfo.read RenderInfo.spec
    , LevelSize.read LevelSize.spec

    ---- NEW "physics"
    , Circles.readCircles playerHurtBoxSpec |> ifPlayer

    ---NEW STUFF
    , Objects.read eventSequenceSpec2
    ]


encoders : List (ShootEmUpWorld -> Encoder)
encoders =
    [ Sprite.encode Sprite.spec
    , Animation.encode Animation.spec
    , AnimationsDict.encode Animation.encodeItem AnimationsDict.spec
    , Ammo.encode Ammo.spec
    , Position.encode Position.spec
    , Input.encode Input.spec
    , RenderInfo.encode RenderInfo.spec
    , LevelSize.encode LevelSize.spec
    , .camera >> E.id

    --    , EventSequence.spec.get >> EventSequence.encode Spawn.encodeItem
    ---- NEW "physics"
    , .playerHitBox >> E.components Circles.encodeCircles
    , .enemyHitBox >> E.components Circles.encodeCircles
    , .playerHurtBox >> E.components Circles.encodeCircles
    , .enemyHurtBox >> E.components Circles.encodeCircles
    ]


decoders : GetTexture -> List (WorldDecoder ShootEmUpWorld)
decoders getTexture =
    [ Sprite.decode Sprite.spec |> withTexture getTexture
    , Animation.decode Animation.spec
    , AnimationsDict.decode Animation.decodeItem AnimationsDict.spec
    , Ammo.decode Ammo.spec |> withTexture getTexture
    , Position.decode Position.spec
    , Input.decode Input.spec
    , RenderInfo.decode RenderInfo.spec
    , LevelSize.decode LevelSize.spec
    , D.id |> D.map (\c w -> { w | camera = c })

    --    , EventSequence.decode (Spawn.decodeItem getTexture) |> D.map EventSequence.spec.set
    ---- NEW "physics"
    , D.components Circles.decodeCircles |> D.map (\c w -> { w | playerHitBox = c })
    , D.components Circles.decodeCircles |> D.map (\c w -> { w | enemyHitBox = c })
    , D.components Circles.decodeCircles |> D.map (\c w -> { w | playerHurtBox = c })
    , D.components Circles.decodeCircles |> D.map (\c w -> { w | enemyHurtBox = c })
    ]


setInitResize =
    Task.map2
        (\{ scene } w ->
            RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
                |> update
        )
        Browser.getViewport


removeEntity id world =
    let
        remove =
            Entity.removeFor Sprite.spec
                >> Entity.removeFor (Input.toComps Input.spec)
                >> Entity.removeFor Position.spec
                >> Entity.removeFor Ammo.spec
                >> Entity.removeFor Animation.spec
                >> Entity.removeFor AnimationsDict.spec
                >> Entity.removeFor Velocity.spec
                >> Entity.removeFor Lifetime.spec
                >> Entity.removeFor AI.spec
                >> Entity.removeFor HitPoints.spec
                >> Entity.removeFor Damage.spec
                >> Entity.removeFor onContactSpec
                >> Entity.removeFor onDeathSpec
                >> Entity.removeFor playerHitBoxSpec
                >> Entity.removeFor enemyHitBoxSpec
                >> Entity.removeFor playerHurtBoxSpec
                >> Entity.removeFor enemyHurtBoxSpec
                >> Entity.removeFor rewardHurtBoxSpec
    in
    ( id
    , world |> Singleton.update IdSource.spec (\c -> { c | pool = id :: c.pool })
    )
        |> remove
        |> Tuple.second


playerHitBoxSpec : Component.Spec Circles { world | playerHitBox : Component.Set Circles }
playerHitBoxSpec =
    { get = .playerHitBox
    , set = \comps world -> { world | playerHitBox = comps }
    }


enemyHitBoxSpec : Component.Spec Circles { world | enemyHitBox : Component.Set Circles }
enemyHitBoxSpec =
    { get = .enemyHitBox
    , set = \comps world -> { world | enemyHitBox = comps }
    }


playerHurtBoxSpec : Component.Spec Circles { world | playerHurtBox : Component.Set Circles }
playerHurtBoxSpec =
    { get = .playerHurtBox
    , set = \comps world -> { world | playerHurtBox = comps }
    }


enemyHurtBoxSpec : Component.Spec Circles { world | enemyHurtBox : Component.Set Circles }
enemyHurtBoxSpec =
    { get = .enemyHurtBox
    , set = \comps world -> { world | enemyHurtBox = comps }
    }


rewardHurtBoxSpec : Component.Spec Circles { world | rewardHurtBox : Component.Set Circles }
rewardHurtBoxSpec =
    { get = .rewardHurtBox
    , set = \comps world -> { world | rewardHurtBox = comps }
    }


onDeathSpec : Component.Spec (List OnDeath) { world | onDeath : Component.Set (List OnDeath) }
onDeathSpec =
    { get = .onDeath
    , set = \comps world -> { world | onDeath = comps }
    }


onContactSpec : Component.Spec (List OnContact) { world | onContact : Component.Set (List OnContact) }
onContactSpec =
    { get = .onContact
    , set = \comps world -> { world | onContact = comps }
    }


eventSequenceSpec2 =
    { get = .events2
    , set = \comps world -> { world | events2 = comps }
    }


maybeSpawn : ( Component.Spec a world, Maybe a ) -> ( EntityID, world ) -> ( EntityID, world )
maybeSpawn ( spec, value ) acc =
    case value of
        Just v ->
            Entity.with ( spec, v ) acc

        Nothing ->
            acc
