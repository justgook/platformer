module Build exposing (build)

import Bytes exposing (Bytes)
import Http
import Json.Decode as Decode exposing (Value)
import Task


build : (String -> Task.Task x ( Bytes, b )) -> Program Value () (Maybe String)
build encoder =
    Platform.worker
        { update = update
        , subscriptions = \_ -> Sub.none
        , init = init encoder
        }


update : Maybe String -> a -> ( (), Cmd msg )
update world _ =
    ( (), Cmd.none )


init : (String -> Task.Task x ( Bytes.Bytes, b )) -> Value -> ( (), Cmd (Maybe String) )
init encoder flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"

        send a =
            Http.task
                { method = "Post"
                , headers = []
                , url = "http://localhost:3000/save-bytes"
                , body = Http.bytesBody "application/game-level" a
                , resolver = Http.stringResolver (\b -> Ok b)
                , timeout = Nothing
                }
    in
    encoder levelUrl
        |> Task.map Tuple.first
        |> Task.andThen (\a -> send a |> Task.map (\_ -> a))
        |> Task.attempt
            (\a ->
                case a of
                    Ok good ->
                        Just "Base64.fromBytes good"

                    Err _ ->
                        Nothing
            )
        |> (\cmd -> ( (), cmd ))
