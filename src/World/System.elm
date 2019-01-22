module World.System exposing (animationsChanger)

import Array exposing (Array)
import Logic.System as System exposing (System, andMap, end, start)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World.Component as Component
import World.Model exposing (World)


animationsChanger : System World
animationsChanger =
    start
        (\( delme, set4 ) ( position, setPosition ) ( _, set1 ) ( velocity, set2 ) animations acc ->
            acc
                -- |> setPosition (Vec2.add velocity position)
                -- |> setPosition (Vec2.add velocity position)
                -- |> setPosition (Vec2.add velocity position)
                |> setPosition (Vec2.add velocity position)
                |> set4 (Vec3.add (vec3 1 1 1) delme)
        )
        Component.delme
        >> andMap Component.positions
        >> andMap Component.dimensions
        >> andMap Component.velocities
        >> andMap Component.animations
        >> end
