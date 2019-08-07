module Landing.Start exposing (Message, Model, files, onDragover, onDrop, update, view)

import Base64
import Dict
import File exposing (File)
import Html exposing (Html, button, div, li, main_, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events
import Json.Decode as Decode exposing (Decoder, field, list)
import Logic.Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.Loader as Loader exposing (CacheTiled(..), textureError, textureOption)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Task exposing (Task)
import Tiled.Level exposing (Level(..))
import Tiled.Tileset
import WebGL.Texture


type Message world msg
    = Drop (Item world msg) (Task Error (List ( String, CacheTiled )))
    | DragOver Int


type alias Model world msg =
    { dragOver : Int
    , items : List (Item world msg)
    }


type alias Item world msg =
    { success : world -> msg
    , fail : String
    , name : String
    , templateUrl : String
    , parse : Level -> CacheTask CacheTiled -> ResourceTask world CacheTiled
    }


update : (String -> msg) -> Message value msg -> { c | dragOver : Int } -> ( { c | dragOver : Int }, Cmd msg )
update fail msg model =
    case msg of
        DragOver i ->
            ( { model | dragOver = i }, Cmd.none )

        Drop { success, parse } cacheTask ->
            let
                cmd =
                    cacheTask
                        |> Task.andThen (ResourceTask.initWithCache "")
                        |> Task.andThen
                            (\cache ->
                                case cache.dict |> Dict.toList |> selectLevel of
                                    Nothing ->
                                        Task.fail (Error 4668 "No level found")

                                    Just url ->
                                        Task.succeed ( url, cache )
                            )
                        |> Task.andThen
                            (\( url, cache ) ->
                                cache
                                    |> (Task.succeed
                                            >> Loader.getLevel url
                                            >> ResourceTask.andThen parse
                                       )
                                    |> ResourceTask.toTask
                            )
                        |> Task.attempt
                            (\world ->
                                case world of
                                    Ok w ->
                                        success w

                                    Err (Error code e) ->
                                        case code of
                                            4100 ->
                                                fail ("Platformer world:" ++ e)

                                            _ ->
                                                fail ("Platformer world:" ++ e)
                            )
            in
            ( model, cmd )


selectLevel : List ( a, CacheTiled ) -> Maybe a
selectLevel l =
    case l of
        ( url, Level_ _ ) :: _ ->
            Just url

        _ :: rest ->
            selectLevel rest

        [] ->
            Nothing


view : Model world msg -> List (Html (Message world msg))
view m =
    let
        game i ({ name } as item) =
            li
                [ onDragover "dragenter" i
                , onDragover "dragleave" 0
                , onDrop item
                , classList
                    [ ( "drag-over", m.dragOver == i )
                    ]
                ]
                [ div []
                    [ if m.dragOver /= i then
                        text name

                      else
                        text ("Drop to Start - \"" ++ name ++ "\" game")
                    , div []
                        [ button [] [ text "Template" ]
                        , Html.a [ class "button" ] [ text "Start" ]
                        ]
                    ]
                ]

        small t =
            li
                [ class "small" ]
                [ div []
                    [ text t
                    ]
                ]

        withSmall =
            li
                [ class "with-small" ]
                [ div []
                    [ text "Coming Soon.."
                    , ul [ class "small-wrapper" ]
                        [ small "1"
                        , small "2"
                        , small "3"
                        , small "4"
                        , small "5"
                        , small "6"
                        , small "7"
                        ]
                    ]
                ]
    in
    [ main_ []
        [ ul [ class "clearfix" ]
            (m.items
                |> List.indexedMap (\i -> game i)
                |> (::) withSmall
            )
        ]
    ]


files : Decoder (Task Error (List ( String, CacheTiled )))
files =
    field "dataTransfer" (field "files" (list File.decoder))
        |> Decode.map
            (List.foldl
                (\a acc ->
                    let
                        name =
                            File.name a
                    in
                    case File.mime a of
                        "image/png" ->
                            (File.toBytes a
                                |> Task.andThen
                                    (Base64.fromBytes
                                        >> Maybe.map
                                            ((++) "data:image/png;base64,"
                                                >> WebGL.Texture.loadWith textureOption
                                                >> Task.mapError (textureError name)
                                                >> Task.map (Texture_ >> Tuple.pair name)
                                            )
                                        >> Maybe.withDefault (Task.fail (Error 4667 "Base64.fromBytes"))
                                    )
                            )
                                :: (File.toBytes a |> Task.map (\data -> ( "bytes::" ++ name, Bytes_ data )))
                                :: acc

                        "application/json" ->
                            (File.toString a
                                |> Task.andThen
                                    (\data ->
                                        case
                                            Decode.decodeString
                                                (Decode.oneOf
                                                    [ Tiled.Level.decode |> Decode.map Level_
                                                    , Tiled.Tileset.decodeFile -1000 |> Decode.map Tileset_
                                                    ]
                                                )
                                                data
                                                |> Result.mapError (Decode.errorToString >> Error 4666)
                                        of
                                            Ok i ->
                                                Task.succeed ( name, i )

                                            Err i ->
                                                Task.fail i
                                    )
                            )
                                :: acc

                        _ ->
                            acc
                )
                []
                >> Task.sequence
            )


onDrop : Item world msg -> Html.Attribute (Message world msg)
onDrop item =
    Html.Events.custom "drop"
        (Decode.map
            (\f_ ->
                { message = Drop item f_
                , stopPropagation = True
                , preventDefault = True
                }
            )
            files
        )


onDragover : String -> Int -> Html.Attribute (Message world msg)
onDragover event i =
    Html.Events.custom event
        (Decode.succeed
            { message = DragOver i
            , stopPropagation = True
            , preventDefault = True
            }
        )
