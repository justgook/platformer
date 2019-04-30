module World.System.Example exposing (linearMovement)

import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


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
