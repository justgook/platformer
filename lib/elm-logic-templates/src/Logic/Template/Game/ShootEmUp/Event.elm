module Logic.Template.Game.ShootEmUp.Event exposing (Event(..), read, spawn)

import Dict
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Component.AI as AI
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.Component.EventSequence as EventSequence exposing (EventSequence)
import Logic.Template.Component.IdSource as IdSource
import Logic.Template.Component.Lifetime as Lifetime
import Logic.Template.Component.Position as Position
import Logic.Template.Component.Sprite as Sprite exposing (Sprite)
import Logic.Template.Input as Input
import Logic.Template.SaveLoad.Ammo as Ammo
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Sprite as Sprite
import Set
import Tiled.Properties exposing (Property(..))


type Event
    = Enemy Sprite Ammo


spawn (Enemy sprite ammo) world =
    spawn_ sprite ammo world


spawn_ sprite ammo =
    entity sprite ammo IdSource.spec Position.spec AI.spec Lifetime.spec Sprite.spec (Input.toComps Input.spec)


entity sprite ammo idSpec posSpec aiSpec lifetimeSpec spriteSpec inputSpec world =
    let
        ai =
            { start = world.frame
            , x = { max = 0.9, min = 0.1, speed = -0.005, start = 0 }
            , y = { max = 1, min = 0.1, speed = 0.0005, start = 1 }
            }

        input =
            Input.emptyComp
    in
    IdSource.create idSpec world
        |> Entity.with ( posSpec, { x = 0, y = 0 } )
        |> Entity.with ( aiSpec, ai )
        |> Entity.with ( lifetimeSpec, 320 )
        |> Entity.with ( spriteSpec, sprite )
        |> Entity.with ( inputSpec, { input | action = Set.insert "Fire" input.action } )
        |> Entity.with ( Ammo.spec, ammo )
        |> Tuple.second


read : Singleton.Spec (EventSequence Event) world -> Reader world
read spec_ =
    { defaultRead
        | objectTile =
            Async
                (\({ properties } as info) ->
                    Sprite.extract info
                        >> ResourceTask.andThen (\sprite -> Ammo.extract info >> ResourceTask.map (Tuple.pair sprite))
                        >> ResourceTask.map
                            (\( sprite, ammo ) ( entityId, world ) ->
                                ( entityId
                                , Maybe.map3
                                    (\a b c ->
                                        case ( a, b, c ) of
                                            ( PropInt repeat, PropInt delay, PropInt interval ) ->
                                                Singleton.update spec_
                                                    (List.range 0 (repeat - 1) |> List.foldl (\i -> (>>) (EventSequence.add ( i * interval + delay, Enemy sprite ammo ))) identity)
                                                    world

                                            _ ->
                                                world
                                    )
                                    (Dict.get "spawn.repeat" properties)
                                    (Dict.get "spawn.delay" properties)
                                    (Dict.get "spawn.interval" properties)
                                    |> Maybe.withDefault world
                                )
                            )
                )
    }
