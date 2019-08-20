module Logic.Template.SaveLoad.Internal.ResourceTask exposing
    ( CacheTask
    , ResourceTask
    , andMap
    , andThen
    , attempt
    , attemptWithCach
    , fail
    , getCache
    , init
    , initWithCache
    , map
    , map2
    , map3
    , map4
    , sequence
    , succeed
    , toTask
    )

import Dict exposing (Dict)
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
    task1 >> andThen (\a -> task2 >> map (\b -> f a b))


map3 :
    (a1 -> a2 -> a3 -> a4)
    -> (CacheTask b -> ResourceTask a1 b)
    -> (CacheTask b -> ResourceTask a2 b)
    -> (CacheTask b -> ResourceTask a3 b)
    -> (CacheTask b -> ResourceTask a4 b)
map3 f task1 task2 task3 =
    task1 >> andThen (\a -> task2 >> andThen (\b -> task3 >> map (\c -> f a b c)))


map4 :
    (a1 -> a2 -> a3 -> a4 -> a5)
    -> (CacheTask b -> ResourceTask a1 b)
    -> (CacheTask b -> ResourceTask a2 b)
    -> (CacheTask b -> ResourceTask a3 b)
    -> (CacheTask b -> ResourceTask a4 b)
    -> (CacheTask b -> ResourceTask a5 b)
map4 f task1 task2 task3 task4 =
    task1 >> andThen (\a -> task2 >> andThen (\b -> task3 >> andThen (\c -> task4 >> map (\d -> f a b c d))))


andMap : (CacheTask b -> ResourceTask a b) -> (CacheTask b -> ResourceTask (a -> c) b) -> CacheTask b -> ResourceTask c b
andMap =
    map2 (|>)


andThen : (a -> CacheTask b -> ResourceTask a1 b) -> ResourceTask a b -> ResourceTask a1 b
andThen f =
    Task.andThen
        (\( a, d1 ) ->
            f a (Task.succeed d1)
                |> Task.map (\( b, d2 ) -> ( b, { d1 | dict = Dict.union d1.dict d2.dict } ))
        )


init : CacheTask b
init =
    Task.succeed { dict = Dict.empty, url = "" }


initWithCache : String -> List ( String, b ) -> CacheTask b
initWithCache url l =
    Task.succeed { dict = Dict.fromList l, url = url }
