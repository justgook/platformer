module Logic.Template.Input.Port exposing (portInput)

import Json.Decode as Decode


portInput ( gamepadDown, gamepadUp ) port_ world =
    --    https://github.com/jeromeetienne/virtualjoystick.js
    gamepadDown
        (\income ->
            let
                _ =
                    income
                        |> Decode.decodeValue Decode.string

                --                        |> Debug.log "gamePad msg"
            in
            world
        )
