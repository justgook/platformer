module Logic.Asset.Camera.Trigger exposing (Trigger, yTrigger)

import Logic.Asset.Camera.Common exposing (Any)


type alias Trigger a =
    Any { a | yTarget : Float }


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
