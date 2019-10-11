module Logic.Template.Game.ShootEmUp.Objects exposing (EnemyTemplate, Event, ExplosionTemplate, OnContact(..), OnDeath(..), RewardTemplate, read)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Dict exposing (Dict)
import Logic.Component.Singleton as Singleton
import Logic.Template.Component.AI exposing (AiTargets)
import Logic.Template.Component.Ammo exposing (Ammo)
import Logic.Template.Component.Animation exposing (Animation)
import Logic.Template.Component.Circles exposing (Circles)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.Component.Sprite exposing (Sprite)
import Logic.Template.Game.ShootEmUp.ReadHelper as ReadHelper
import Logic.Template.SaveLoad.Ammo as Ammo
import Logic.Template.SaveLoad.Animation as Animation
import Logic.Template.SaveLoad.Circles as Circles
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (ExtractAsync, Read(..), TileData, WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Logic.Template.SaveLoad.Internal.Util as Util
import Logic.Template.SaveLoad.Sprite as Sprite
import Tiled exposing (gidInfo)
import Tiled.NestedProperties as NestedProperties
import Tiled.Object
import Tiled.Properties


type alias Event =
    EnemyTemplate


type alias EnemyTemplate =
    { sprite : Sprite
    , animation : Maybe Animation
    , ammo : Ammo
    , hurtbox : Circles
    , targets : AiTargets
    , lifetime : Maybe Int
    , hp : Int
    , onContact : List OnContact
    , onDeath : List OnDeath
    }


type alias ExplosionTemplate =
    { anim : Maybe Animation
    , sprite : Sprite
    , offset : Vec2

    --    , onContact : OnContact
    }


type alias RewardTemplate =
    { anim : Maybe Animation
    , sprite : Sprite
    , offset : Vec2
    , hurtbox : Circles
    , onContact : List OnContact
    }


type OnContact
    = SetAmmo String
    | Damage Int


type OnDeath
    = SpawnExplosion ExplosionTemplate
    | SpawnReward RewardTemplate
    | SpawnEnemy Vec2 EnemyTemplate
    | LoadLevel String


read : Singleton.Spec (EventSequence Event) world -> WorldReader world
read spec_ =
    { defaultRead
        | objectTile =
            Async
                (\({ properties } as info) ->
                    let
                        toTileArg tile =
                            Reader.tileArgs info.level info.layer tile (gidInfo tile.gid)

                        newInfo =
                            case Dict.get "spawn.object" properties of
                                Just (Tiled.Properties.PropInt reference) ->
                                    case Util.objectByIdInLevel reference info.level of
                                        Just (Tiled.Object.Tile tileData) ->
                                            toTileArg tileData

                                        _ ->
                                            info

                                _ ->
                                    info
                    in
                    case ( Dict.get "spawn.repeat" properties, Dict.get "spawn.delay" properties, Dict.get "spawn.interval" properties ) of
                        ( Just (Tiled.Properties.PropInt repeat), Just (Tiled.Properties.PropInt delay), Just (Tiled.Properties.PropInt interval) ) ->
                            extractEvent
                                { repeat = repeat
                                , delay = delay
                                , interval = interval
                                , lifetime = (Util.properties info).int "spawn.lifetime"
                                }
                                newInfo
                                >> ResourceTask.map (Singleton.update spec_ >> Tuple.mapSecond)

                        _ ->
                            ResourceTask.succeed identity
                )
    }


extractEvent : { a | repeat : Int, delay : Int, interval : Int, lifetime : Maybe Int } -> TileData -> ExtractAsync (EventSequence Event -> EventSequence Event)
extractEvent { repeat, delay, interval, lifetime } info =
    let
        onDeathTask =
            ResourceTask.map2 (\a b -> a ++ b ++ extractLoadLevel info)
                (extractExplosion info)
                (extractReward info)
    in
    ResourceTask.succeed
        (\sprite animation ammo circles onDeath ->
            let
                targets_ =
                    ReadHelper.aiTargets info.level info.properties info.layer.objects

                lifetime_ =
                    lifetime
                        |> orMaybe ((Util.properties info).int "spawn.lifetime")

                hitPoints =
                    (Util.propertiesWithDefault info).int "hp" 10
            in
            List.range 0 (repeat - 1)
                |> List.foldl
                    (\i ->
                        (>>)
                            (EventSequence.add
                                ( i * interval + delay
                                , { sprite = sprite
                                  , animation = animation
                                  , ammo = ammo
                                  , hurtbox = circles |> Maybe.withDefault [ ( vec2 0 0, info.width * 0.5 ) ]
                                  , targets = targets_
                                  , lifetime = lifetime_
                                  , hp = hitPoints
                                  , onContact = []
                                  , onDeath = onDeath
                                  }
                                )
                            )
                    )
                    identity
        )
        |> ResourceTask.andMap (Sprite.extract info)
        |> ResourceTask.andMap (Animation.extract info)
        |> ResourceTask.andMap (Ammo.extract info)
        |> ResourceTask.andMap (Circles.extractCircles info.level info.gid)
        |> ResourceTask.andMap onDeathTask


extractExplosion : TileData -> ExtractAsync (List OnDeath)
extractExplosion info =
    let
        explosion item =
            getGid item
                |> Maybe.map
                    (\gid_ ->
                        ResourceTask.map2
                            (\anim sprite ->
                                SpawnExplosion
                                    { anim = anim
                                    , sprite = sprite
                                    , offset = getOffset item |> Maybe.withDefault (vec2 0 0)
                                    }
                            )
                            (Animation.extract { info | gid = gid_ })
                            (Sprite.extract { info | gid = gid_ })
                    )
    in
    oneOrMany explosion [ "onDeath", "explosion" ] info.properties


extractReward : TileData -> ExtractAsync (List OnDeath)
extractReward info =
    let
        reward item =
            getGid item
                |> Maybe.map
                    (\gid_ ->
                        ResourceTask.succeed
                            (\anim sprite ammoName circles ->
                                SpawnReward
                                    { anim = anim
                                    , sprite = sprite
                                    , offset = getOffset item |> Maybe.withDefault (vec2 0 0)
                                    , onContact = [ SetAmmo ammoName ]
                                    , hurtbox = circles |> Maybe.withDefault [ ( vec2 0 0, info.width * 0.5 ) ]
                                    }
                            )
                            |> ResourceTask.andMap (Animation.extract { info | gid = gid_ })
                            |> ResourceTask.andMap (Sprite.extract { info | gid = gid_ })
                            |> ResourceTask.andMap (item |> NestedProperties.get "setAmmo" |> Maybe.map string |> Maybe.withDefault "" |> ResourceTask.succeed)
                            |> ResourceTask.andMap (Circles.extractCircles info.level gid_)
                    )
    in
    oneOrMany reward [ "onDeath", "reward" ] info.properties


extractLoadLevel : { a | properties : Tiled.Properties.Properties } -> List OnDeath
extractLoadLevel info =
    NestedProperties.convert info.properties
        |> NestedProperties.at [ "onDeath", "loadLevel" ]
        |> Maybe.map (string >> LoadLevel >> List.singleton)
        |> Maybe.withDefault []


oneOrMany : (NestedProperties.Property -> Maybe (ExtractAsync a)) -> List String -> Tiled.Properties.Properties -> ExtractAsync (List a)
oneOrMany f path properties =
    NestedProperties.convert properties
        |> NestedProperties.at path
        |> Maybe.map
            (\p ->
                f p
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault
                        (p
                            |> NestedProperties.values
                            |> List.map f
                            |> List.foldr foldrValues []
                        )
                    |> ResourceTask.sequence
            )
        |> Maybe.withDefault (ResourceTask.succeed [])


getGid : NestedProperties.Property -> Maybe Int
getGid item =
    Maybe.map2 (+)
        (item |> NestedProperties.get "id" |> Maybe.map int)
        (item |> NestedProperties.get "tileset" |> Maybe.map int)


getOffset : NestedProperties.Property -> Maybe Vec2
getOffset item =
    Maybe.map2 Vec2
        (item |> NestedProperties.at [ "offset", "y" ] |> Maybe.map float)
        (item |> NestedProperties.at [ "offset", "x" ] |> Maybe.map float)


float : NestedProperties.Property -> Float
float p_ =
    case p_ of
        NestedProperties.PropInt p ->
            toFloat p

        NestedProperties.PropFloat p ->
            p

        _ ->
            0


int : NestedProperties.Property -> Int
int p_ =
    case p_ of
        NestedProperties.PropInt p ->
            p

        NestedProperties.PropFloat p ->
            round p

        _ ->
            0


string : NestedProperties.Property -> String
string p_ =
    case p_ of
        NestedProperties.PropString p ->
            p

        NestedProperties.PropFile p ->
            p

        _ ->
            ""


foldrValues : Maybe a -> List a -> List a
foldrValues item list =
    case item of
        Nothing ->
            list

        Just v ->
            v :: list


orMaybe : Maybe a -> Maybe a -> Maybe a
orMaybe ma mb =
    case ma of
        Nothing ->
            mb

        Just _ ->
            ma
