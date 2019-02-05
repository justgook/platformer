module World.System exposing (animationsChanger, demoCamera)

import Array exposing (Array)
import Ease exposing (Easing)
import List.Nonempty as NE exposing (Nonempty)
import Logic.System as System exposing (System, andMap, end, start)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World.Component as Component
import World.Model exposing (World)


demoCamera : Easing -> Nonempty Vec3 -> System World
demoCamera easing points world =
    -- https://package.elm-lang.org/packages/elm-community/easing-functions/latest/Ease
    let
        speed =
            70

        now =
            toFloat world.frame / speed

        index =
            floor now

        value =
            easing (now - toFloat index)

        current =
            NE.get index points

        next =
            NE.get (index + 1) points

        { x, y, z } =
            Vec3.sub next current
                |> Vec3.scale value
                |> Vec3.add current
                |> Vec3.toRecord
    in
    { world | camera = { pixelsPerUnit = z, viewportOffset = vec2 x y } }


animationsChanger : System World
animationsChanger world =
    (start
        (\( delme, set4 ) ( position, setPosition ) ( _, set1 ) ( velocity, set2 ) animations acc ->
            -- let
            --     _ =
            --         Debug.log "animationsChanger" world.delme
            -- in
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
    )
        world
