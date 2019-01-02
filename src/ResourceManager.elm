module ResourceManager exposing (RemoteData(..), init)

import Http
import Json.Decode as Decode
import Task exposing (Task)
import Tiled.Level as Tiled


type RemoteData e a
    = Loading
    | Failure e
    | Success a


init : (Tiled.Level -> Task Http.Error a) -> (Http.Error -> Task e a) -> Decode.Value -> ( RemoteData e1 a1, Cmd (RemoteData e a) )
init succeed fail flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"
    in
    ( Loading, getLevel succeed fail levelUrl )


getLevel : (Tiled.Level -> Task Http.Error a) -> (Http.Error -> Task e a) -> String -> Cmd (RemoteData e a)
getLevel succeed fail url =
    Http.get url Tiled.decode
        |> Http.toTask
        |> Task.andThen succeed
        |> Task.onError fail
        |> Task.attempt
            (\r ->
                case r of
                    Ok s ->
                        Success s

                    Err e ->
                        Failure e
            )
