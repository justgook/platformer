module Logic.Template.Game.ShootEmUp.Spawn exposing (Event(..), decodeExplosion, decodeItem, encodeExplosion, encodeItem, entity, read)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict exposing (Dict)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Component.AI as AI exposing (AiPercentage)
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.Component.Animation exposing (Animation)
import Logic.Template.Component.Circles exposing (Circles)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.Component.IdSource as IdSource
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Input as Input
import Logic.Template.SaveLoad.AI as AI
import Logic.Template.SaveLoad.Ammo as Ammo
import Logic.Template.SaveLoad.Animation as Animation
import Logic.Template.SaveLoad.Circles as Circles
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (GetTexture)
import Logic.Template.SaveLoad.Internal.Util as Util
import Logic.Template.SaveLoad.Sprite as Sprite
import Maybe exposing (Maybe)
import Parser exposing ((|.), (|=), Parser)
import Tiled.Object exposing (Object)
import Tiled.Properties exposing (Property(..))


type Event
    = Enemy
        { sprite : Sprite
        , ammo : Ammo
        , hurtbox : Circles
        , explosion : Explosion
        , targets : AiPercentage
        , lifetime : Int
        , hp : Int
        }


type alias Explosion =
    Maybe ( Animation, Sprite )


encodeExplosion : Explosion -> Encoder
encodeExplosion =
    Maybe.map
        (\( anim, sprite ) ->
            E.sequence
                [ E.id 1
                , Animation.encodeItem anim
                , sprite |> Sprite.encodeSprite
                ]
        )
        >> Maybe.withDefault (E.id 0)


decodeExplosion : GetTexture -> Decoder Explosion
decodeExplosion getTexture =
    D.id
        |> D.andThen
            (\i ->
                if i == 1 then
                    D.map2 (\a b -> Just ( a, b )) Animation.decodeItem (Sprite.decodeSprite getTexture)

                else
                    D.succeed Nothing
            )


encodeItem (Enemy data) =
    E.sequence
        [ data.sprite |> Sprite.encodeSprite
        , data.ammo |> Ammo.encodeItem
        , data.hurtbox |> Circles.encodeCircles
        , data.explosion |> encodeExplosion
        , data.targets |> AI.encodeOne
        , data.lifetime |> E.id
        , data.hp |> E.id
        ]


decodeItem : GetTexture -> Decoder Event
decodeItem getTexture =
    D.succeed
        (\sprite ammo hurtbox explosion targets lifetime hp ->
            Enemy
                { sprite = sprite
                , ammo = ammo
                , hurtbox = hurtbox
                , explosion = explosion
                , targets = targets
                , lifetime = lifetime
                , hp = hp
                }
        )
        |> D.andMap (Sprite.decodeSprite getTexture)
        |> D.andMap (Ammo.decodeItem getTexture)
        |> D.andMap Circles.decodeCircles
        |> D.andMap (decodeExplosion getTexture)
        |> D.andMap AI.decodeOne
        |> D.andMap D.id
        |> D.andMap D.id


entity (Enemy { sprite, ammo, hurtbox, explosion, targets, lifetime, hp }) idSpec hpSpec deadFx posSpec velSpec aiSpec2 lifetimeSpec spriteSpec ammoSpec inputSpec enemyHurtBoxSpec world =
    let
        input =
            Input.emptyComp

        startPos =
            targets.target.position
                |> Vec2.mul { x = world.render.virtualScreen.width, y = world.render.virtualScreen.height }
                |> (\a -> Vec2.sub a { x = world.render.virtualScreen.width * 0.5, y = 0 })

        target =
            targets.target
    in
    IdSource.create idSpec world
        |> Entity.with ( posSpec, startPos )
        |> Entity.with ( velSpec, { x = 0, y = 0 } )
        |> Entity.with ( aiSpec2, { targets | target = { target | position = startPos } } )
        |> Entity.with ( lifetimeSpec, lifetime )
        |> Entity.with ( spriteSpec, sprite )
        |> Entity.with ( inputSpec, input )
        |> Entity.with ( ammoSpec, ammo )
        |> Entity.with ( hpSpec, hp )
        |> maybeSpawn ( deadFx, explosion )
        |> Entity.with ( enemyHurtBoxSpec, hurtbox )
        |> Tuple.second


maybeSpawn ( spec, value ) acc =
    case value of
        Just v ->
            Entity.with ( spec, v ) acc

        Nothing ->
            acc


read : Singleton.Spec (EventSequence Event) world -> WorldReader world
read spec_ =
    { defaultRead
        | objectTile =
            Async
                (\({ properties, layer, level, width } as info) ->
                    let
                        maybeRepeat =
                            Dict.get "spawn.repeat" properties

                        maybeDelay =
                            Dict.get "spawn.delay" properties

                        maybeInterval =
                            Dict.get "spawn.interval" properties
                    in
                    if maybeRepeat == Nothing || maybeDelay == Nothing || maybeInterval == Nothing then
                        ResourceTask.succeed identity

                    else
                        let
                            props =
                                Util.properties info

                            levelCommon =
                                Util.levelCommon level

                            levelWidth =
                                toFloat (levelCommon.tilewidth * levelCommon.width)

                            levelHeight =
                                toFloat (levelCommon.tileheight * levelCommon.height)

                            yInvert =
                                Util.objFix levelHeight
                                    >> toPercentage levelWidth levelHeight

                            getExplosion =
                                Maybe.map2
                                    (\tileID firstgid ->
                                        Animation.extract { info | gid = tileID + firstgid }
                                            >> ResourceTask.andThen
                                                (Maybe.map
                                                    (\anim ->
                                                        Sprite.extract { info | gid = tileID + firstgid }
                                                            >> ResourceTask.map (Tuple.pair anim >> Just)
                                                    )
                                                    >> Maybe.withDefault (ResourceTask.succeed Nothing)
                                                )
                                    )
                                    (props.int "spawn.onKill.id")
                                    (props.int "spawn.onKill.tileset")
                                    |> Maybe.withDefault (ResourceTask.succeed Nothing)
                        in
                        ResourceTask.map4
                            (\sprite ammo hurtbox explosion ( entityId, world ) ->
                                ( entityId
                                , Maybe.map3
                                    (\repeat_ delay_ interval_ ->
                                        case ( repeat_, delay_, interval_ ) of
                                            ( PropInt repeat, PropInt delay, PropInt interval ) ->
                                                let
                                                    targets_ =
                                                        aiTargets yInvert properties layer.objects

                                                    lifetime =
                                                        (Util.propertiesWithDefault info).int "spawn.lifetime" 100

                                                    hitPoints =
                                                        (Util.propertiesWithDefault info).int "spawn.hp" 10
                                                in
                                                Singleton.update spec_
                                                    (List.range 0 (repeat - 1)
                                                        |> List.foldl
                                                            (\i ->
                                                                (>>)
                                                                    (EventSequence.add
                                                                        ( i * interval + delay
                                                                        , Enemy
                                                                            { sprite = sprite
                                                                            , ammo = ammo
                                                                            , hurtbox = hurtbox |> Maybe.withDefault [ ( vec2 0 0, width / 2 ) ]
                                                                            , explosion = explosion
                                                                            , targets = targets_
                                                                            , lifetime = lifetime
                                                                            , hp = hitPoints
                                                                            }
                                                                        )
                                                                    )
                                                            )
                                                            identity
                                                    )
                                                    world

                                            _ ->
                                                world
                                    )
                                    maybeRepeat
                                    maybeDelay
                                    maybeInterval
                                    |> Maybe.withDefault world
                                )
                            )
                            (Sprite.extract info)
                            (Ammo.extract info)
                            (Circles.extractCircles info)
                            getExplosion
                )
    }


aiTargets :
    (Object -> Object)
    -> Dict String Property
    -> List Object
    -> AiPercentage
aiTargets yInvert props objList =
    props
        |> Dict.foldl (addItem yInvert objList) Dict.empty
        |> Dict.values
        |> (\l ->
                case l of
                    target :: rest ->
                        { waiting = 0
                        , prev = [ target ]
                        , target = target
                        , next = rest
                        }

                    [] ->
                        { waiting = 0
                        , prev = []
                        , target = AI.emptySpot
                        , next = []
                        }
           )


addItem yInvert objList key value acc =
    let
        setPos pos mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | position = pos }

        setAction action mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | action = action :: spot.action }

        setWait wait mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | wait = wait }

        setInvSteps steps mValue =
            let
                spot =
                    Maybe.withDefault AI.emptySpot mValue
            in
            Just { spot | invSteps = 1 / toFloat steps }
    in
    case ( Parser.run aiKeyParser key, value ) of
        ( Ok ( Index, index ), PropInt id ) ->
            Util.objectById id objList
                |> Maybe.map (yInvert >> Util.objectPosition)
                |> Maybe.map (\pos -> Dict.update index (setPos pos) acc)
                |> Maybe.withDefault acc

        ( Ok ( Action, index ), PropString action ) ->
            Dict.update index (setAction action) acc

        ( Ok ( Wait, index ), PropInt wait ) ->
            Dict.update index (setWait wait) acc

        ( Ok ( Steps, index ), PropInt steps ) ->
            Dict.update index (setInvSteps steps) acc

        _ ->
            acc


type AiKey
    = Wait
    | Index
    | Action
    | Steps


aiKeyParser : Parser ( AiKey, Int )
aiKeyParser =
    Parser.succeed
        (\index key ->
            ( key, index )
        )
        |. Parser.keyword "ai.target"
        |= Parser.oneOf
            [ Parser.succeed identity |. Parser.symbol "[" |= Parser.int |. Parser.symbol "]"
            , Parser.succeed 0
            ]
        |= Parser.oneOf
            [ Parser.succeed Index |. Parser.end
            , Parser.succeed Wait |. Parser.symbol ".wait" |. Parser.end
            , Parser.succeed Action |. Parser.symbol ".action" |. Parser.end
            , Parser.succeed Steps |. Parser.symbol ".steps" |. Parser.end
            ]


toPercentage width height obj =
    case obj of
        Tiled.Object.Point c ->
            Tiled.Object.Point { c | x = c.x / width, y = c.y / height }

        Tiled.Object.Rectangle c ->
            Tiled.Object.Rectangle { c | x = c.x / width, y = c.y / height }

        Tiled.Object.Ellipse c ->
            Tiled.Object.Ellipse { c | x = c.x / width, y = c.y / height }

        Tiled.Object.Polygon c ->
            Tiled.Object.Polygon { c | x = c.x / width, y = c.y / height }

        Tiled.Object.PolyLine c ->
            Tiled.Object.PolyLine { c | x = c.x / width, y = c.y / height }

        Tiled.Object.Tile c ->
            Tiled.Object.Tile { c | x = c.x / width, y = c.y / height }
