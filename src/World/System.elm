module World.System exposing (animChange, autoScrollCamera, demoCamera, linearMovement)

import Dict
import Ease exposing (Easing)
import List.Nonempty as NE exposing (Nonempty)
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World exposing (WorldTuple)
import World.Component.Object exposing (Object(..))
import World.DirectionHelper as Dir exposing (fromRecord)


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



--    { tileSet : Texture
--    , tileSetSize : Vec2
--    , tileSize : Vec2
--    , mirror : Vec2
--    , animLUT : Texture
--    , animLength : Int
--    }


animChange dirSpec objSpec animSpec ( common, ecs ) =
    let
        newEcs =
            System.step3
                (\( dir, _ ) ( obj_, setObj ) ( anim, _ ) acc ->
                    case ( obj_, Dict.get ( "walk", Dir.fromRecord dir |> Dir.toInt ) anim ) of
                        ( Animated obj, Just a ) ->
                            acc
                                |> setObj
                                    (Animated
                                        { obj
                                            | tileSet = a.tileSet
                                            , tileSetSize = a.tileSetSize
                                            , tileSize = a.tileSize
                                            , mirror = a.mirror
                                            , animLUT = a.animLUT
                                            , animLength = a.animLength
                                        }
                                    )

                        _ ->
                            acc
                )
                dirSpec
                objSpec
                animSpec
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

        { x, y } =
            camera.viewportOffset
                |> Vec2.add speed
                |> Vec2.add rand_
                |> Vec2.toRecord

        newX =
            x
                |> round
                |> modBy 724200
                |> toFloat
    in
    ( { common
        | camera = { camera | viewportOffset = vec2 newX y }
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
