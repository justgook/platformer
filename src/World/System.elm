module World.System exposing (autoScrollCamera, demoCamera, linearMovement)

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
            System.step2
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


autoScrollCamera : Vec2 -> Vec2 -> WorldTuple world -> WorldTuple world
autoScrollCamera speed rand ( common, ecs ) =
    let
        camera =
            common.camera

        rand_ =
            Vec2.scale (sin (toFloat common.frame / 30)) rand
                |> Vec2.sub (Vec2.scale (sin (toFloat (common.frame - 1) / 30)) rand)

        newPos =
            camera.viewportOffset
                |> Vec2.add speed
                |> Vec2.add rand_
    in
    ( { common
        | camera = { camera | viewportOffset = newPos }
      }
    , ecs
    )


demoCamera : Easing -> List Vec3 -> WorldTuple world -> WorldTuple world
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
