module World.System exposing (demoCamera, linearMovement)

import Ease exposing (Easing)
import List.Nonempty as NE exposing (Nonempty)
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World exposing (WorldTuple)


linearMovement posSpec dirSpec ( common, ecs ) =
    let
        speed =
            3

        newEcs =
            System.foldl2
                (\( pos, setPos ) ( { x, y }, _ ) acc ->
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


demoCamera : Easing -> List Vec3 -> WorldTuple world object -> WorldTuple world object
demoCamera easing points_ ( common, ecs ) =
    let
        points =
            NE.fromList points_
                |> Maybe.withDefault
                    (vec3 0 0 common.camera.pixelsPerUnit |> NE.fromElement)

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
