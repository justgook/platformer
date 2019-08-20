module Logic.Template.Camera.CameraPath exposing (Points, centerStep, points, step)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Template.Camera.Common exposing (LegacyAny, LegacyCamera, LegacyWithId)
import Logic.Template.Internal exposing (Points(..), get)


points =
    Logic.Template.Internal.points


type alias Points =
    Logic.Template.Internal.Points


step : (Float -> Float) -> Points -> Int -> LegacyAny a -> LegacyAny a
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


centerStep : (Float -> Float) -> Points -> Vec2 -> Int -> LegacyAny a -> LegacyAny a
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
