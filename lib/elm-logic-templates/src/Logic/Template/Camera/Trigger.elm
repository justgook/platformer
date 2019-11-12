module Logic.Template.Camera.Trigger exposing (Trigger, yTrigger)

import AltMath.Vector2
import Logic.Template.Camera.Common exposing (LegacyAny)


type alias Trigger a =
    LegacyAny { a | yTarget : Float }


yTrigger speed =
    do (linear_ speed)


do f maybeY target cam =
    case maybeY of
        Just yTarget ->
            let
                newCam =
                    f yTarget cam
            in
            { newCam | yTarget = yTarget }

        Nothing ->
            f cam.yTarget cam


linear_ speed value cam =
    let
        viewportOffset =
            AltMath.Vector2.toRecord cam.viewportOffset

        distance =
            viewportOffset.y - value

        speed_ =
            if distance < 0 then
                -speed

            else
                speed

        newY =
            viewportOffset.y - speed_
    in
    if (distance * distance) > speed * speed && ((0 < distance && newY < viewportOffset.y) || (0 > distance && newY > viewportOffset.y)) then
        { cam
            | viewportOffset = AltMath.Vector2.setY newY cam.viewportOffset
        }

    else
        { cam
            | viewportOffset = AltMath.Vector2.setY value cam.viewportOffset
        }
