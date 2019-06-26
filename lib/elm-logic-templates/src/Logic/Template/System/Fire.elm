module Logic.Template.System.Fire exposing (spawn)

import AltMath.Vector2 as Vec2
import Logic.Entity as Entity exposing (EntityID)
import Logic.System exposing (applyIf)
import Logic.Template.Component.Ammo as Ammo
import Logic.Template.Component.IdSource as IdSource
import Logic.Template.Input as Input
import Set


spawn idSpec inputSpec_ ammoSpec posSpec velocitySpec lifetimeSpec spriteSpec world =
    let
        inputSpec =
            Input.toComps inputSpec_

        combined =
            { a = inputSpec.get world
            , b = posSpec.get world
            , c = ammoSpec.get world
            , d = velocitySpec.get world
            , e = lifetimeSpec.get world
            , f = spriteSpec.get world
            , g = idSpec.get world
            , frame = world.frame
            }

        result =
            Logic.System.foldl3 spawnSystem combined.a combined.b combined.c combined
    in
    world
        |> applyIf (result.b /= combined.b) (posSpec.set result.b)
        |> applyIf (result.d /= combined.d) (velocitySpec.set result.d)
        |> applyIf (result.e /= combined.e) (lifetimeSpec.set result.e)
        |> applyIf (result.f /= combined.f) (spriteSpec.set result.f)
        |> applyIf (result.g /= combined.g) (idSpec.set result.g)


spawnSystem key pos ammo acc =
    let
        lifetime =
            100
    in
    if Set.member "Fire" key.action then
        case Ammo.get "0" ammo of
            Just templates ->
                List.foldl
                    (\template acc_ ->
                        if modBy template.fireRate acc.frame == 0 then
                            IdSource.create gSpec acc_
                                |> Entity.with ( bSpec, Vec2.add pos template.offset )
                                |> Entity.with ( dSpec, template.velocity )
                                |> Entity.with ( eSpec, lifetime )
                                |> Entity.with ( fSpec, template.sprite )
                                |> Tuple.second

                        else
                            acc_
                    )
                    acc
                    templates

            Nothing ->
                acc

    else
        acc


aSpec =
    { get = .a
    , set = \comps world -> { world | a = comps }
    }


bSpec =
    { get = .b
    , set = \comps world -> { world | b = comps }
    }


dSpec =
    { get = .d
    , set = \comps world -> { world | d = comps }
    }


eSpec =
    { get = .e
    , set = \comps world -> { world | e = comps }
    }


fSpec =
    { get = .f
    , set = \comps world -> { world | f = comps }
    }


gSpec =
    { get = .g
    , set = \comps world -> { world | g = comps }
    }
