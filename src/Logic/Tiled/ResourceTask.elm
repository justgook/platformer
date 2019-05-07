module Logic.Tiled.ResourceTask exposing
    ( CacheTask
    , ResourceTask
    , Response
    , andThen
    , attempt
    , attemptWithCach
    , fail
    , getCache
    , getLevel
    , getTexture
    , getTileset
    , init
    , map
    , map2
    , sequence
    , succeed
    , toTask
    )

import Defaults exposing (default)
import Dict exposing (Dict)
import Error exposing (Error(..))
import Http
import Json.Decode as Decode exposing (Decoder)
import Task exposing (Task)
import Tiled.Level
import Tiled.Tileset
import WebGL.Texture


type Response
    = Texture WebGL.Texture.Texture
    | Tileset Tiled.Tileset.Tileset
    | Level Tiled.Level.Level


type alias ResourceTask a =
    Task Error ( a, Cache )


type alias CacheTask =
    Task Error Cache


type alias Cache =
    { url : String
    , dict : Dict.Dict String Response
    }


attempt : (Result Error a -> msg) -> ResourceTask a -> Cmd msg
attempt f =
    Task.map Tuple.first >> Task.attempt f


toTask : ResourceTask a -> Task Error a
toTask =
    Task.map Tuple.first


attemptWithCach : (Result Error ( a, Cache ) -> msg) -> ResourceTask a -> Cmd msg
attemptWithCach f =
    Task.attempt f


sequence : List (CacheTask -> ResourceTask a) -> CacheTask -> ResourceTask (List a)
sequence ltask cache =
    List.foldl
        (\t acc ->
            acc
                |> andThen
                    (\newList t2 ->
                        t t2
                            |> map (\r -> r :: newList)
                    )
        )
        (succeed [] cache)
        ltask


getTileset : String -> Int -> CacheTask -> ResourceTask Tiled.Tileset.Tileset
getTileset url firstgid =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Tileset r) ->
                    Task.succeed ( r, d )

                _ ->
                    getJson (d.url ++ url) (Tiled.Tileset.decodeFile firstgid) |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert url (Tileset resp) d.dict } )
            )


getTexture : String -> CacheTask -> ResourceTask WebGL.Texture.Texture
getTexture url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Texture r) ->
                    Task.succeed ( r, d )

                _ ->
                    (if String.startsWith "data:image" url then
                        url

                     else
                        d.url ++ url
                    )
                        |> WebGL.Texture.loadWith default.textureOption
                        |> Task.mapError (textureError url)
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert url (Texture resp) d.dict } )
            )


textureError : String -> WebGL.Texture.Error -> Error
textureError url e =
    case e of
        WebGL.Texture.LoadError ->
            Error 4005 ("Texture.LoadError: " ++ url)

        WebGL.Texture.SizeError a b ->
            Error 4006 ("Texture.SizeError: " ++ url)


getLevel : String -> CacheTask -> ResourceTask Tiled.Level.Level
getLevel url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Level r) ->
                    Task.succeed ( r, d )

                _ ->
                    getJson url Tiled.Level.decode |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                let
                    relUrl =
                        String.split "/" url
                            |> List.reverse
                            |> List.drop 1
                            |> (::) ""
                            |> List.reverse
                            |> String.join "/"
                in
                ( resp, { d | url = relUrl, dict = Dict.insert url (Level resp) d.dict } )
            )


succeed : a -> CacheTask -> ResourceTask a
succeed a =
    Task.andThen (Tuple.pair a >> Task.succeed)


fail : Error -> CacheTask -> ResourceTask a
fail e _ =
    Task.fail e


getCache : ResourceTask a -> CacheTask
getCache =
    Task.map Tuple.second


map : (a -> b) -> ResourceTask a -> ResourceTask b
map f task =
    Task.map (Tuple.mapFirst f) task


map2 :
    (a2 -> a1 -> b)
    -> (CacheTask -> ResourceTask a2)
    -> (CacheTask -> ResourceTask a1)
    -> CacheTask
    -> ResourceTask b
map2 f task1 task2 =
    --TODO validate cache pass from first to second task
    task1 >> andThen (\a -> task2 >> map (\b -> f a b))


andThen : (a -> CacheTask -> ResourceTask b) -> ResourceTask a -> ResourceTask b
andThen f =
    Task.andThen
        (\( a, d1 ) ->
            f a (Task.succeed d1)
                |> Task.map (\( b, d2 ) -> ( b, { d1 | dict = Dict.union d1.dict d2.dict } ))
        )


getJson : String -> Decoder a -> Task.Task Error a
getJson url decoder =
    Http.task
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
                                |> Result.mapError (Decode.errorToString >> Error 4004)

                        Http.BadUrl_ info ->
                            Err (Error 4000 info)

                        Http.Timeout_ ->
                            Err (Error 4001 "Timeout")

                        Http.NetworkError_ ->
                            Err (Error 4002 "NetworkError")

                        Http.BadStatus_ { statusCode } _ ->
                            Err (Error 4003 ("BadStatus:" ++ String.fromInt statusCode))
                )
        , timeout = Nothing
        }


init : CacheTask
init =
    Task.succeed { dict = Dict.empty, url = "" }
