module World.System exposing (linearMovement)

import Dict
import Ease exposing (Easing)
import List.Nonempty as NE exposing (Nonempty)
import Logic.Component
import Logic.Component.Singleton
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World exposing (WorldTuple)
import World.Component.Camera exposing (Camera)


linearMovement posSpec dirSpec ( common, ecs ) =
    let
        speed =
            3

        newEcs =
            System.step2
                (\( pos, setPos ) ( { x, y }, _ ) acc ->
                    acc
                        |> (vec2 (x * speed) (y * speed)
                                |> Vec2.add pos
                                |> setPos
                           )
                )
                posSpec
                dirSpec
                ecs
    in
    ( common, newEcs )
