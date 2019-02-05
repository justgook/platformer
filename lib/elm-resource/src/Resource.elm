module Resource exposing (Model, Resource, getJson, init, task, update, when)

import Array exposing (Array)
import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Task exposing (Task)


type Resource a
    = Resource Int String a


type Pending result
    = Pending
    | Done result


type Model result msg
    = Model
        { store :
            Array.Array
                { file : String
                , pending : Pending result
                }
        , msg :
            Resource (Result Http.Error result)
            -> msg
        , posponded :
            Dict.Dict String (List (result -> ( Model result msg, Cmd msg ) -> ( Model result msg, Cmd msg )))
        }



-- type ResourceData a e r msg
--     = NotAsked
--     | Loading { data : Array r, msg : msg }
--     | Failure e
--     | Success a


init msg =
    ( Model
        { store = Array.empty
        , msg = msg
        , posponded = Dict.empty
        }
    , Cmd.none
    )


wrap a =
    Model a


unwrap (Model a) =
    a


wrapUnwrap f acc =
    acc |> Tuple.mapFirst wrap |> f |> Tuple.mapFirst unwrap


update (Resource i file result) (Model model_) =
    case result of
        Ok good ->
            let
                ( model, cmd ) =
                    Dict.get file model_.posponded
                        |> Maybe.map (List.foldr (\f -> wrapUnwrap (f good)) ( model_, Cmd.none ))
                        |> Maybe.withDefault ( model_, Cmd.none )
                        |> Tuple.mapFirst (\m -> { m | posponded = Dict.remove file m.posponded })
            in
            ( Model
                { model
                    | store =
                        model.store
                            |> updateArray i (\a -> { a | pending = Done good })
                }
            , cmd
            )

        Err a ->
            ( Model model_, Cmd.none )


task name f ( Model model, cmd ) =
    if findFileIndex name model.store 0 == -1 then
        ( Model
            { model
                | store = Array.push { file = name, pending = Pending } model.store
            }
        , Cmd.batch
            [ f
                |> Task.attempt
                    (Resource (Array.length model.store) name >> model.msg)
            , cmd
            ]
        )

    else
        ( Model model, cmd )



-- getJson url decoder ( Model model, cmd ) =
--     if findFileIndex url model.store 0 == -1 then
--         ( Model
--             { model
--                 | store = Array.push { file = url, pending = Pending } model.store
--             }
--         , Cmd.batch
--             [ getJson_ url decoder
--                 |> Task.attempt
--                     (Resource (Array.length model.store) url >> model.msg)
--             , cmd
--             ]
--         )
--     else
--         ( Model model, cmd )


when requires f ( Model model, cmd ) =
    let
        index =
            findFileIndex requires model.store 0
    in
    case Array.get index model.store of
        Just { file, pending } ->
            case pending of
                Done a ->
                    ( Model model, cmd )

                Pending ->
                    let
                        posponded =
                            model.posponded
                                |> addOrCreate file f
                    in
                    ( Model { model | posponded = posponded }, cmd )

        Nothing ->
            ( Model model, cmd )


addOrCreate k v d =
    Dict.update k (Maybe.map ((::) v) >> Maybe.withDefault [ v ] >> Just) d


updateArray : Int -> (a -> a) -> Array a -> Array a
updateArray n f a =
    let
        element =
            Array.get n a
    in
    case element of
        Nothing ->
            a

        Just element_ ->
            Array.set n (f element_) a


findFileIndex : String -> Array { a | file : String } -> Int -> Int
findFileIndex file arr i =
    case Array.get i arr of
        Just info ->
            if info.file == file then
                i

            else
                findFileIndex file arr (i + 1)

        Nothing ->
            -1


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
