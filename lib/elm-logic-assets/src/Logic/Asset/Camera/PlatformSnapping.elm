module Logic.Asset.Camera.PlatformSnapping exposing (PlatformSnapping, step)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Asset.Camera.Common exposing (Any)
import Logic.Asset.Internal exposing (Points(..))



--step : (Float -> Float) -> Points -> Int -> Any a -> Any a


type alias PlatformSnapping a =
    Any { a | yTarget : Float }


step maybeY target cam =
    case maybeY of
        Just yTarget ->
            let
                newCam =
                    tween yTarget cam
            in
            { newCam | yTarget = yTarget }

        Nothing ->
            tween cam.yTarget cam


tween y cam =
    let
        newY =
            (cam.viewportOffset.y + y) / 2

        distance =
            cam.viewportOffset.y - newY
    in
    if (distance * distance) > 1 then
        { cam
            | viewportOffset = { x = cam.viewportOffset.x, y = newY }
        }

    else
        { cam
            | viewportOffset = { x = cam.viewportOffset.x, y = y }
        }
