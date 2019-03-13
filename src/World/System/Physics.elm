module World.System.Physics exposing (movement, physic)

import Logic.System
import Math.Vector2 as Vec2 exposing (vec2)
import Physic.Body


physic bodySpec ( common, ecs ) =
    let
        updater body =
            """Broad.Grid.query (boundary body) ecs.collisions
                |> Dict.keys
                |> List.map toRect
                |> Physics.updateOld body
                Logic.System.step updater bodySpec"""
    in
    ( common, ecs )


movement bodySpec inputSpec ( common, ecs ) =
    let
        newEcs =
            Logic.System.step2
                (\( body, setBody ) ( { x, y }, _ ) acc ->
                    let
                        velocity =
                            Vec2.scale 3 (vec2 x y)

                        updatedBody =
                            Physic.Body.setVelocity velocity body
                    in
                    setBody updatedBody acc
                )
                bodySpec
                inputSpec
                ecs
    in
    ( common, newEcs )
