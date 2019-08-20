module Logic.Template.Camera.Smoothing exposing (smooth, xSmooth, ySmooth)

import AltMath.Vector2 exposing (Vec2)
import Logic.Template.Camera.Common exposing (LegacyAny)


smooth : Vec2 -> LegacyAny a -> LegacyAny a
smooth target cam =
    { cam | viewportOffset = target }


xSmooth : Vec2 -> LegacyAny a -> LegacyAny a
xSmooth target cam =
    { cam | viewportOffset = { x = target.x, y = cam.viewportOffset.y } }


ySmooth : Vec2 -> LegacyAny a -> LegacyAny a
ySmooth target cam =
    { cam | viewportOffset = { x = cam.viewportOffset.x, y = target.y } }


tween y cam =
    let
        distance =
            cam.viewportOffset.y - y

        newY =
            cam.viewportOffset.y - distance * 0.5
    in
    if (distance * distance) > 1 then
        { cam
            | viewportOffset = { x = cam.viewportOffset.x, y = newY }
        }

    else
        { cam
            | viewportOffset = { x = cam.viewportOffset.x, y = y }
        }


linear_ speed value cam =
    let
        distance =
            cam.viewportOffset.y - value

        newDistance =
            if distance < 0 then
                -speed

            else
                speed

        newY =
            cam.viewportOffset.y - newDistance
    in
    if (distance * distance) > 1 && ((0 < distance && newY < cam.viewportOffset.y) || (0 > distance && newY > cam.viewportOffset.y)) then
        { cam
            | viewportOffset = { x = cam.viewportOffset.x, y = newY }
        }

    else
        { cam
            | viewportOffset = { x = cam.viewportOffset.x, y = value }
        }
