module World.System exposing (demoCamera, linearMovement)

import Array exposing (Array)
import Ease exposing (Easing)
import List.Nonempty as NE exposing (Nonempty)
import Logic.System as System exposing (System, andMap, end, start)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World exposing (World(..))
import World.Component as Component


linearMovement posSpec dirSpec ( common, ecs ) =
    let
        speed =
            3

        newEcs =
            System.foldl2
                (\( pos, setPos ) ( { x, y }, setDir ) acc ->
                    acc
                        |> (vec2 (toFloat x * speed) (toFloat y * speed)
                                |> Vec2.add pos
                                |> setPos
                           )
                )
                posSpec
                dirSpec
                ecs
    in
    ( common, newEcs )


demoCamera easing points ( common, ecs ) =
    let
        speed =
            60

        now =
            toFloat common.frame / speed

        index =
            floor now

        current =
            NE.get index points

        value =
            easing (now - toFloat index)

        next =
            NE.get (index + 1) points

        { x, y, z } =
            Vec3.sub next current
                |> Vec3.scale value
                |> Vec3.add current
                |> Vec3.toRecord
    in
    ( { common
        | camera = { pixelsPerUnit = z, viewportOffset = vec2 x y }
      }
    , ecs
    )



-- animationsChanger world =
--     (start
--         (\( delme, set4 ) ( position, setPosition ) ( _, set1 ) ( velocity, set2 ) animations acc ->
--             -- let
--             --     _ =
--             --         Debug.log "animationsChanger" world.delme
--             -- in
--             acc
--                 -- |> setPosition (Vec2.add velocity position)
--                 -- |> setPosition (Vec2.add velocity position)
--                 -- |> setPosition (Vec2.add velocity position)
--                 |> setPosition (Vec2.add velocity position)
--                 |> set4 (Vec3.add (vec3 1 1 1) delme)
--         )
--         Component.delme
--         >> andMap Component.positions
--         >> andMap Component.dimensions
--         >> andMap Component.velocities
--         >> andMap Component.animations
--         >> end
--     )
--         world
