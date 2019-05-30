port module Build exposing (init, main, update)

import Base64
import Common exposing (OwnWorld, emptyWorld, encoders, read)
import Json.Decode as Decode exposing (Value)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Layer exposing (lutCollector)
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
    SaveLoad.loadTiledAndEncode levelUrl emptyWorld read encoders lutCollector
        |> ResourceTask.toTask
        |> Task.map Tuple.first
        |> Task.attempt
            (\a ->
                case a of
                    Ok good ->
                        good |> Base64.fromBytes

                    Err _ ->
                        Nothing
            )
        |> (\cmd -> ( (), cmd ))
