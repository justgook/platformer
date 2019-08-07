module Logic.Template.System.Fire exposing (spawn)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.System exposing (applyIf)
import Logic.Template.Component.Ammo as Ammo
import Logic.Template.Component.Hurt as Hurt exposing (Circles, spawnHitBox)
import Logic.Template.Component.IdSource as IdSource
import Logic.Template.Input as Input
import Set


spawn idSpec hurtSpec inputSpec_ ammoSpec posSpec velocitySpec lifetimeSpec spriteSpec world =
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
            , h = hurtSpec.get world
            , frame = world.frame
            }

        targetId =
            0

        targetPos =
            Entity.get targetId combined.b
                |> Maybe.withDefault { x = 0, y = 0 }

        result =
            Logic.System.indexedFoldl3 (spawnSystem ( targetId, targetPos )) combined.a combined.b combined.c combined
    in
    world
        |> applyIf (result.b /= combined.b) (posSpec.set result.b)
        |> applyIf (result.d /= combined.d) (velocitySpec.set result.d)
        |> applyIf (result.e /= combined.e) (lifetimeSpec.set result.e)
        --        |> applyIf (result.f /= combined.f) (spriteSpec.set result.f)
        {- CAN NOT validate textures as they tend to cause runtime error -}
        |> applyIf (result.e /= combined.e) (spriteSpec.set result.f)
        |> applyIf (result.g /= combined.g) (idSpec.set result.g)
        |> applyIf (result.h /= combined.h) (hurtSpec.set result.h)


spawnSystem ( targetId, targetPos ) i key pos ammo acc =
    let
        lifetime =
            100

        hitBox : Circles
        hitBox =
            ( vec2 10 10, 5 )

        velocity template =
            --            if i /= targetId then
            --                Vec2.direction targetPos pos
            --                    |> Vec2.scale 10
            --
            --            else
            template.velocity
    in
    if Set.member "Fire" key.action then
        case Ammo.get "0" ammo of
            Just templates ->
                List.foldl
                    (\template acc_ ->
                        if modBy template.fireRate acc.frame == 0 then
                            IdSource.create gSpec acc_
                                |> Entity.with ( bSpec, Vec2.add pos template.offset )
                                |> Entity.with ( dSpec, velocity template )
                                |> Entity.with ( eSpec, lifetime )
                                |> Entity.with ( fSpec, template.sprite )
                                |> hitWith i ( hSpec, ( template.damage, hitBox ) )
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


hitWith author ( spec_, hitbox_ ) ( entityID, w ) =
    ( entityID, Singleton.update spec_ (spawnHitBox author ( entityID, hitbox_ )) w )


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


hSpec =
    { get = .h
    , set = \comps world -> { world | h = comps }
    }
