module ResourceManager3 exposing (Model, ResourceStorage, andThen, attempt, getJson, init, update)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Task exposing (Task)
import Tiled.Level
import Tiled.Tileset
import WebGL.Texture


type ResourceStorage
    = Image WebGL.Texture.Texture
    | Tileset Tiled.Tileset.Tileset
    | Level Tiled.Level.Level


type alias Model =
    MiddleDownload ResourceStorage


type alias MiddleDownload a =
    Dict String a


update msg model =
    let
        _ =
            Debug.log "ResourceManager3.update" msg
    in
    ( model, Cmd.none )


init =
    Dict.empty


type alias ResourceTask x a =
    ( String, Task x a )


andThen : (a -> ResourceTask x b) -> ResourceTask x a -> ResourceTask x b
andThen f ( s, task ) =
    ( s, Task.andThen (\r -> f r |> Tuple.second) task )


attempt : (( String, Result x a ) -> msg) -> ResourceTask x a -> Cmd msg
attempt f ( s, task ) =
    Task.attempt (Tuple.pair s >> f) task


getJson : String -> Decode.Decoder a -> ResourceTask Http.Error a
getJson url decoder =
    ( url
    , Http.task
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , resolver =
            Http.stringResolver
                (\response ->
                    case response of
                        Http.GoodStatus_ meta body ->
                            Decode.decodeString decoder body
                                |> Result.mapError (Decode.errorToString >> Http.BadBody)

                        Http.BadUrl_ info ->
                            Err (Http.BadUrl info)

                        Http.Timeout_ ->
                            Err Http.Timeout

                        Http.NetworkError_ ->
                            Err Http.NetworkError

                        Http.BadStatus_ { statusCode } _ ->
                            Err (Http.BadStatus statusCode)
                )
        , timeout = Nothing
        }
    )
