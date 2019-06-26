port module Build exposing (init, main, update)

import Base64
import Json.Decode as Decode exposing (Value)
import Logic.Template.Game.Platformer as Platformer
import Task


main : Program Value () (Maybe String)
main =
    Platform.worker
        { update = update
        , subscriptions = \_ -> Sub.none
        , init = init
        }


port bytes : String -> Cmd msg


update : Maybe String -> a -> ( (), Cmd msg )
update world _ =
    ( (), world |> Maybe.map bytes |> Maybe.withDefault Cmd.none )


init : Value -> ( (), Cmd (Maybe String) )
init flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"
    in
    Platformer.encode levelUrl
        |> Task.map Tuple.first
        |> Task.attempt
            (\a ->
                case a of
                    Ok good ->
                        Base64.fromBytes good

                    Err _ ->
                        Nothing
            )
        |> (\cmd -> ( (), cmd ))
