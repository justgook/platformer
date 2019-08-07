module Logic.Template.System.Control exposing (platformer, shootEmUp)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Collision.Physic.AABB
import Collision.Physic.Narrow.AABB as AABB exposing (AABB)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.System exposing (System, applyIf)
import Logic.Template.Component.Physics as PhysicsComponent
import Logic.Template.Component.SFX as AudioSprite exposing (AudioSprite)
import Logic.Template.Input as Input exposing (InputSingleton)
import Set


shootEmUp speed inputSpec_ posSpec { width, height } world =
    let
        inputSpec =
            Input.toComps inputSpec_
    in
    Logic.System.step2
        (\( { x, y }, _ ) ( pos, setPos ) ->
            { x = pos.x + x * speed.x
            , y = pos.y + y * speed.y
            }
                |> setPos
        )
        inputSpec
        posSpec
        world


platformer :
    Vec2
    -> Singleton.Spec InputSingleton world
    -> Singleton.Spec PhysicsComponent.World world
    -> Singleton.Spec AudioSprite world
    -> System world
platformer force inputSpec_ physicsSpec audioSpec world =
    let
        engine =
            physicsSpec.get world

        inputSpec =
            Input.toComps inputSpec_

        setBody : EntityID -> AABB Int -> { b | a : Component.Set (AABB Int) } -> { b | a : Component.Set (AABB Int) }
        setBody index value acc_ =
            { acc_ | a = Component.set index value acc_.a }

        combined =
            { a = engine |> Collision.Physic.AABB.getIndexed |> Entity.fromList
            , b = inputSpec.get world
            , c = audioSpec.get world
            }

        addSound =
            AudioSprite.spawn { get = .c, set = \comps w -> { w | c = comps } }

        result =
            Logic.System.indexedFoldl2
                (\i body_ key acc ->
                    case ( key.x, Set.member "Jump" key.action ) of
                        ( a, True ) ->
                            if .y (AABB.getContact body_) == -1 then
                                acc
                                    |> setBody i (AABB.setVelocity (vec2 (key.x * force.x) force.y) body_)
                                    |> addSound (AudioSprite.sound "Jump")

                            else if a == 0 then
                                setBody i (AABB.updateVelocity (\v -> { v | x = 0 }) body_) acc

                            else
                                setBody i (AABB.updateVelocity (\v -> { v | x = key.x * force.x }) body_) acc

                        ( a, False ) ->
                            if a == 0 then
                                setBody i (AABB.updateVelocity (\v -> { v | x = 0 }) body_) acc

                            else
                                setBody i (AABB.updateVelocity (\v -> { v | x = key.x * force.x }) body_) acc
                )
                combined.a
                combined.b
                combined
    in
    world
        |> applyIf (result.a /= combined.a) (physicsSpec.set { engine | indexed = result.a |> Entity.toDict })
        --                |> applyIf (result.b /= combined.b) (spec2.set result.b)--Never Happens - it is just reading
        |> applyIf (result.c /= combined.c) (audioSpec.set result.c)
