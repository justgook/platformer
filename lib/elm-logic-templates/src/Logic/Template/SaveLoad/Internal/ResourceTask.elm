module Logic.Template.SaveLoad.Internal.ResourceTask exposing
    ( CacheTask
    , ResourceTask
    , andThen
    , attempt
    , attemptWithCach
    , fail
    , getCache
    , getJson
    , init
    , map
    , map2
    , sequence
    , succeed
    , toTask
    )

import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import Logic.Launcher exposing (Error(..))
import Task exposing (Task)


type alias ResourceTask a b =
    Task Error ( a, Cache b )


type alias CacheTask a =
    Task Error (Cache a)


type alias Cache a =
    { url : String
    , dict : Dict.Dict String a
    }


attempt : (Result Error a -> msg) -> ResourceTask a b -> Cmd msg
attempt f =
    Task.map Tuple.first >> Task.attempt f


toTask : ResourceTask a b -> Task Error a
toTask =
    Task.map Tuple.first


attemptWithCach : (Result Error ( a, Cache b ) -> msg) -> ResourceTask a b -> Cmd msg
attemptWithCach f =
    Task.attempt f


sequence : List (CacheTask b -> ResourceTask a b) -> CacheTask b -> ResourceTask (List a) b
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


succeed : a -> CacheTask b -> ResourceTask a b
succeed a =
    Task.andThen (Tuple.pair a >> Task.succeed)


fail : Error -> CacheTask b -> ResourceTask a b
fail e _ =
    Task.fail e


getCache : ResourceTask a b -> CacheTask b
getCache =
    Task.map Tuple.second


map : (a -> c) -> ResourceTask a b -> ResourceTask c b
map f task =
    Task.map (Tuple.mapFirst f) task


map2 :
    (a1 -> a2 -> a3)
    -> (CacheTask b -> ResourceTask a1 b)
    -> (CacheTask b -> ResourceTask a2 b)
    -> (CacheTask b -> ResourceTask a3 b)
map2 f task1 task2 =
    --TODO validate cache pass from first to second task
    task1 >> andThen (\a -> task2 >> map (\b -> f a b))


andThen : (a -> CacheTask b -> ResourceTask a1 b) -> ResourceTask a b -> ResourceTask a1 b
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


init : CacheTask b
init =
    Task.succeed { dict = Dict.empty, url = "" }
