module Logic.Asset.Camera.CameraPath exposing (Points, centerStep, points, step)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Asset.Camera.Common exposing (Any, Camera, WithId)
import Logic.Asset.Internal exposing (Points(..), get)


points =
    Logic.Asset.Internal.points


type alias Points =
    Logic.Asset.Internal.Points


step : (Float -> Float) -> Points -> Int -> Any a -> Any a
step easing (Points points_) frame cam =
    let
        speed =
            60

        now =
            toFloat frame / speed

        index =
            floor now

        current =
            get index points_

        value =
            easing (now - toFloat index)

        next =
            get (index + 1) points_

        viewportOffset =
            Vec2.sub next current
                |> Vec2.scale value
                |> Vec2.add current
    in
    { cam | viewportOffset = viewportOffset }


centerStep : (Float -> Float) -> Points -> Vec2 -> Int -> Any a -> Any a
centerStep easing (Points points_) center frame cam =
    let
        speed =
            60

        now =
            toFloat frame / speed

        index =
            floor now

        current =
            get index points_

        value =
            easing (now - toFloat index)

        next =
            get (index + 1) points_

        viewportOffset =
            Vec2.sub next current
                |> Vec2.scale value
                |> Vec2.add current
                |> Vec2.sub center
    in
    { cam | viewportOffset = viewportOffset }



--clamp
