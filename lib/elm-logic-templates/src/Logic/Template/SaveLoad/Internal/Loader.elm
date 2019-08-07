module Logic.Template.SaveLoad.Internal.Loader exposing
    ( CacheBytes(..)
    , CacheTiled(..)
    , GetTileset
    , TaskBytes
    , TaskTiled
    , getBytes
    , getBytesTiled
    , getJson
    , getLevel
    , getLut
    , getTexture
    , getTextureTiled
    , getTileset
    , textureError
    , textureOption
    )

import Base64
import Bytes exposing (Bytes)
import Dict
import Http
import Json.Decode as Decode exposing (Decoder, Value)
import Logic.Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.ResourceTask exposing (CacheTask, ResourceTask)
import Task
import Tiled.Level
import Tiled.Tileset exposing (Tileset)
import WebGL.Texture exposing (linear, nonPowerOfTwoOptions)


type CacheTiled
    = Texture_ WebGL.Texture.Texture
    | Tileset_ Tiled.Tileset.Tileset
    | Level_ Tiled.Level.Level
    | Json_ Value
    | Bytes_ Bytes.Bytes


type CacheBytes
    = Texture WebGL.Texture.Texture
    | Bytes Bytes.Bytes


type alias TaskTiled a =
    CacheTask CacheTiled -> ResourceTask a CacheTiled


type alias TaskBytes a =
    CacheTask CacheBytes -> ResourceTask a CacheBytes


type alias GetTileset =
    Int -> TaskTiled Tileset


getTileset : String -> Int -> CacheTask CacheTiled -> ResourceTask Tiled.Tileset.Tileset CacheTiled
getTileset url firstgid =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Tileset_ r) ->
                    (case r of
                        Tiled.Tileset.Embedded content ->
                            ( Tiled.Tileset.Embedded { content | firstgid = firstgid }, d )

                        Tiled.Tileset.Source content ->
                            ( Tiled.Tileset.Source { content | firstgid = firstgid }, d )

                        Tiled.Tileset.ImageCollection content ->
                            ( Tiled.Tileset.ImageCollection { content | firstgid = firstgid }, d )
                    )
                        |> Task.succeed

                _ ->
                    getJson_ (d.url ++ url) (Tiled.Tileset.decodeFile firstgid)
                        |> Task.map
                            (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert url (Tileset_ resp) d.dict } )
            )


getTextureTiled : String -> CacheTask CacheTiled -> ResourceTask WebGL.Texture.Texture CacheTiled
getTextureTiled url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Texture_ r) ->
                    Task.succeed ( r, d )

                _ ->
                    (if String.startsWith "data:image" url then
                        url

                     else
                        d.url ++ url
                    )
                        |> WebGL.Texture.loadWith textureOption
                        |> Task.mapError (textureError url)
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) -> ( resp, { d | dict = Dict.insert url (Texture_ resp) d.dict } ))


getTexture : String -> CacheTask CacheBytes -> ResourceTask WebGL.Texture.Texture CacheBytes
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
                        |> WebGL.Texture.loadWith textureOption
                        |> Task.mapError (textureError url)
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) -> ( resp, { d | dict = Dict.insert url (Texture resp) d.dict } ))



--getLut : Int -> Int -> Int -> Image.BMP.PixelData -> CacheTask CacheBytes -> ResourceTask WebGL.Texture.Texture CacheBytes


getLut : Int -> Bytes -> CacheTask CacheBytes -> ResourceTask WebGL.Texture.Texture CacheBytes
getLut id image =
    let
        name =
            String.fromInt id |> (++) "____"
    in
    Task.andThen
        (\d ->
            case Dict.get name d.dict of
                Just (Texture r) ->
                    Task.succeed ( r, d )

                _ ->
                    let
                        url2 =
                            image
                                |> Base64.fromBytes
                                |> Maybe.withDefault ""
                                |> (++) "data:image/png;base64,"
                    in
                    url2
                        |> WebGL.Texture.loadWith textureOption
                        |> Task.mapError (textureError name)
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) -> ( resp, { d | dict = Dict.insert name (Texture resp) d.dict } ))


getBytesTiled : String -> CacheTask CacheTiled -> ResourceTask Bytes.Bytes CacheTiled
getBytesTiled url =
    Task.andThen
        (\d ->
            case Dict.get ("bytes::" ++ url) d.dict of
                Just (Bytes_ r) ->
                    Task.succeed ( r, d )

                _ ->
                    (d.url ++ url)
                        |> getBytes_
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert ("bytes::" ++ url) (Bytes_ resp) d.dict } )
            )


getBytes : String -> TaskBytes Bytes.Bytes
getBytes url =
    Task.andThen
        (\d ->
            case Dict.get ("bytes::" ++ url) d.dict of
                Just (Bytes r) ->
                    Task.succeed ( r, d )

                _ ->
                    (d.url ++ url)
                        |> getBytes_
                        |> Task.map (\r -> ( r, d ))
        )
        >> Task.map
            (\( resp, d ) ->
                ( resp, { d | dict = Dict.insert ("bytes::" ++ url) (Bytes resp) d.dict } )
            )


textureOption : WebGL.Texture.Options
textureOption =
    { nonPowerOfTwoOptions
        | magnify = linear
        , minify = linear
    }


textureError : String -> WebGL.Texture.Error -> Error
textureError url e =
    case e of
        WebGL.Texture.LoadError ->
            Error 4005 ("Texture.LoadError: " ++ url)

        WebGL.Texture.SizeError a b ->
            Error 4006 ("Texture.SizeError: " ++ url)


getLevel : String -> CacheTask CacheTiled -> ResourceTask Tiled.Level.Level CacheTiled
getLevel url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Level_ r) ->
                    Task.succeed ( r, d )

                _ ->
                    getJson_ url Tiled.Level.decode |> Task.map (\r -> ( r, d ))
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
                ( resp, { d | url = relUrl, dict = Dict.insert url (Level_ resp) d.dict } )
            )


getJson : String -> CacheTask CacheTiled -> ResourceTask Value CacheTiled
getJson url =
    Task.andThen
        (\d ->
            case Dict.get url d.dict of
                Just (Json_ r) ->
                    Task.succeed ( r, d )

                _ ->
                    getJson_ (d.url ++ url) Decode.value |> Task.map (\r -> ( r, d ))
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
                ( resp, { d | url = relUrl, dict = Dict.insert url (Json_ resp) d.dict } )
            )


getJson_ : String -> Decoder a -> Task.Task Error a
getJson_ url decoder =
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
                                |> Result.mapError (Decode.errorToString >> Error 4005)

                        Http.BadUrl_ info ->
                            Err (Error 4001 info)

                        Http.Timeout_ ->
                            Err (Error 4002 "Timeout")

                        Http.NetworkError_ ->
                            Err (Error 4003 "NetworkError")

                        Http.BadStatus_ err _ ->
                            case err.statusCode of
                                404 ->
                                    Err (Error 4100 url)

                                _ ->
                                    Err (Error 4004 ("BadStatus:" ++ String.fromInt err.statusCode))
                )
        , timeout = Nothing
        }


getBytes_ : String -> Task.Task Error Bytes.Bytes
getBytes_ url =
    Http.task
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , resolver =
            Http.bytesResolver
                (\response ->
                    case response of
                        Http.GoodStatus_ meta body ->
                            Ok body

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
