port module Game exposing (main)

import Base64
import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.Platformer as Platformer
import Task


game : Launcher.Document flags Platformer.World
game =
    Platformer.game


main : Launcher Value Platformer.World
main =
    --    Launcher.document { game | init = init }
    --    Launcher.document { game | init = debugInit }
    Launcher.document { game | init = \_ -> Platformer.load "./assets/demo.json" }



--    Launcher.document { game | init = init }


init : Value -> Task.Task Launcher.Error Platformer.World
init flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "url" Decode.string)
                |> Result.withDefault "default.bin"

        woldBytes =
            flags
                |> Decode.decodeValue (Decode.field "world" Decode.string)
                |> Result.toMaybe
                |> Maybe.andThen Base64.toBytes
    in
    Maybe.map Platformer.decode woldBytes
        |> Maybe.withDefault (Platformer.run levelUrl)


debugInit : Value -> Task.Task Launcher.Error Platformer.World
debugInit flags =
    Platformer.encode "./ThomasLean/level.json"
        --    Platformer.encode "./assets/demo.json"
        --    Platformer.encoadde "./elm-europe/slides2.json"
        |> Task.andThen
            (\( b, w ) ->
                --                let
                --                    _ =
                --                        Base64.fromBytes
                --                            b
                --
                --                    --                            |> Debug.log "Base64.toBytes"
                --                in
                Platformer.decode b
             --                Task.succeed w
            )
