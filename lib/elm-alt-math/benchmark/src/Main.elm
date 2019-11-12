module Main exposing (main)

import Benchmark exposing (Benchmark)
import Benchmark.Reporting exposing (Report(..))
import Benchmark.Status as Status exposing (Status(..))
import Browser
import CustomRunner.Humanize as Humanize
import Dict exposing (Dict)
import Html
import Html.Attributes exposing (class, classList, disabled, value)
import Html.Events exposing (onClick, onInput)
import Process
import Task exposing (Task)
import Trend.Linear as Trend exposing (Quick, Trend)
import Vector2
import Vector3
import Vector4


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> ( initModel, Cmd.none )
        , view =
            \model ->
                { title = "Math Benchmark"
                , body =
                    [ Html.node "link" [ Html.Attributes.rel "stylesheet", Html.Attributes.href "https://cdn.jsdelivr.net/npm/bulma@0.8.0/css/bulma.min.css" ] []
                    , Html.div [ class "tile" ]
                        [ reportTop (vec2Inputs model.running model.inputs.vec2) model "Vector2" (Vector2.all model.inputs.vec2)
                        , reportTop (vec3Inputs model.running model.inputs.vec3) model "Vector3" (Vector3.all model.inputs.vec3)
                        , reportTop (vec4Inputs model.running model.inputs.vec4) model "Vector4" (Vector4.all model.inputs.vec4)
                        ]
                    ]
                }
        , update = update
        , subscriptions = \model -> Sub.none
        }


dataInput attr name v =
    Html.div [ class "tile is-11 field has-addons" ]
        [ Html.p [ class "control " ]
            [ Html.a [ class "button is-static is-small" ]
                [ Html.text name ]
            ]
        , Html.p [ class "control is-expanded" ]
            [ Html.input
                [ class "input is-small"
                , value v
                , attr
                ]
                []
            ]
        ]


vec2Inputs block { x1, x2, y1, y2 } =
    let
        attr set =
            if block then
                disabled True

            else
                onInput (set >> Input)
    in
    Html.div []
        [ Html.div [ class "tile box" ]
            [ Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec2 specX1).set) "x1" x1
                , dataInput (attr (cursor specVec2 specX2).set) "x2" x2
                ]
            , Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec2 specY1).set) "y1" y1
                , dataInput (attr (cursor specVec2 specY2).set) "y2" y2
                ]
            ]
        ]


vec3Inputs block { x1, x2, y1, y2, z1, z2 } =
    let
        attr set =
            if block then
                disabled True

            else
                onInput (set >> Input)
    in
    Html.div []
        [ Html.div [ class "tile box" ]
            [ Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec3 specX1).set) "x1" x1
                , dataInput (attr (cursor specVec3 specX2).set) "x2" x2
                ]
            , Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec3 specY1).set) "y1" y1
                , dataInput (attr (cursor specVec3 specY2).set) "y2" y2
                ]
            , Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec3 specZ1).set) "z1" z1
                , dataInput (attr (cursor specVec3 specZ2).set) "z2" z2
                ]
            ]
        ]


vec4Inputs block { x1, x2, y1, y2, z1, z2, w1, w2 } =
    let
        attr set =
            if block then
                disabled True

            else
                onInput (set >> Input)
    in
    Html.div []
        [ Html.div [ class "tile box" ]
            [ Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec4 specX1).set) "x1" x1
                , dataInput (attr (cursor specVec4 specX2).set) "x2" x2
                ]
            , Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec4 specY1).set) "y1" y1
                , dataInput (attr (cursor specVec4 specY2).set) "y2" y2
                ]
            , Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec4 specZ1).set) "z1" z1
                , dataInput (attr (cursor specVec4 specZ2).set) "z2" z2
                ]
            , Html.div [ class "tile is-child" ]
                [ dataInput (attr (cursor specVec4 specW1).set) "w1" w1
                , dataInput (attr (cursor specVec4 specW2).set) "w2" w2
                ]
            ]
        ]


reportTop inputs model name l =
    Html.aside [ class "tile is-parent is-vertical" ]
        [ inputs
        , Html.h2 [ class "has-text-weight-bold is-size-3" ] [ Html.text name ]
        , Html.ul [ class "menu-list" ]
            (List.map
                (\bench ->
                    Dict.get (bench |> getName |> (++) (name ++ "::")) model.done
                        |> Maybe.withDefault bench
                        |> report model.running name
                )
                l
            )
        ]


getName bench =
    case bench |> Benchmark.Reporting.fromBenchmark of
        Single name _ ->
            name

        Series name l ->
            name

        Group name l ->
            name


report block topName bench =
    case bench |> Benchmark.Reporting.fromBenchmark of
        Single name _ ->
            Html.li [] [ Html.text ("Single::" ++ name) ]

        Series name l ->
            Html.li []
                [ Html.p [ class "level-left" ]
                    [ Html.div [ class "level-item has-text-weight-bold" ] [ Html.text name ]
                    , Html.button
                        ((if block then
                            disabled True

                          else
                            onClick (Step (topName ++ "::" ++ name) bench)
                         )
                            :: [ class "level-item button is-primary is-small is-rounded"
                               ]
                        )
                        [ Html.text "Start" ]
                    ]
                , Html.ul []
                    (List.map
                        (\( nn, s ) ->
                            Html.li []
                                [ Html.span [ class "has-text-weight-semibold" ] [ Html.text nn ]
                                , contents s
                                ]
                        )
                        l
                    )
                ]

        Group name l ->
            Html.li [] [ Html.text ("Group::" ++ name) ]


update msg model =
    case msg of
        Step s benchmark ->
            if Benchmark.done benchmark then
                ( { model
                    | done = Dict.insert s benchmark model.done
                    , running = False
                  }
                , Cmd.none
                )

            else
                ( { model
                    | done = Dict.insert s benchmark model.done
                    , running = True
                  }
                , Benchmark.step benchmark
                    |> breakForRender
                    |> Task.perform (Step s)
                )

        Input fn ->
            ( { model | inputs = fn model.inputs }, Cmd.none )


type Msg
    = Step String Benchmark
    | Input (InputsData -> InputsData)


type alias Model =
    { done : Dict String Benchmark
    , running : Bool
    , inputs : InputsData
    }


type alias InputsData =
    { vec2 : { x1 : String, x2 : String, y1 : String, y2 : String }
    , vec3 : { x1 : String, x2 : String, y1 : String, y2 : String, z1 : String, z2 : String }
    , vec4 : { x1 : String, x2 : String, y1 : String, y2 : String, z1 : String, z2 : String, w1 : String, w2 : String }
    }


initModel : Model
initModel =
    { done = Dict.empty
    , running = False
    , inputs =
        { vec2 = { x1 = "1", x2 = "2", y1 = "10", y2 = "20" }
        , vec3 = { x1 = "1", x2 = "2", y1 = "10", y2 = "20", z1 = "3", z2 = "4" }
        , vec4 = { x1 = "1", x2 = "2", y1 = "10", y2 = "20", z1 = "3", z2 = "4", w1 = "30", w2 = "40" }
        }
    }


contents status =
    case status of
        Success _ trend ->
            Html.div [ class "level-left" ]
                [ Html.div [ class "level-item has-text-centered" ]
                    [ Html.div []
                        [ Html.p [ class "title is-size-4" ] [ runsPerSecond trend |> Html.text ]
                        , Html.p [ class "heading" ] [ Html.text "runs / second" ]
                        ]
                    ]
                , Html.div [ class "level-item has-text-centered " ]
                    [ Html.div []
                        [ Html.p [ class "title is-size-4" ] [ goodnessOfFit trend |> Html.text ]
                        , Html.p [ class "heading" ] [ Html.text "goodness of fit" ]
                        ]
                    ]
                ]

        Cold ->
            Html.span [] [ Html.text " Cold" ]

        _ ->
            let
                percent =
                    Status.progress status
            in
            Html.progress
                [ class "progress is-primary"
                , percent |> String.fromFloat |> value
                , Html.Attributes.max "1"
                ]
                []


runsPerSecond : Trend a -> String
runsPerSecond =
    Trend.line >> (\a -> Trend.predictX a 1000) >> floor >> Humanize.int


goodnessOfFit : Trend Quick -> String
goodnessOfFit =
    Trend.goodnessOfFit >> Humanize.percent


breakForRender : Task x a -> Task x a
breakForRender task =
    Task.andThen (\_ -> task) (Process.sleep 0)


specX1 =
    { get = .x1
    , set = \comps world -> { world | x1 = comps }
    }


specX2 =
    { get = .x2
    , set = \comps world -> { world | x2 = comps }
    }


specY1 =
    { get = .y1
    , set = \comps world -> { world | y1 = comps }
    }


specY2 =
    { get = .y2
    , set = \comps world -> { world | y2 = comps }
    }


specZ1 =
    { get = .z1
    , set = \comps world -> { world | z1 = comps }
    }


specZ2 =
    { get = .z2
    , set = \comps world -> { world | z2 = comps }
    }


specW1 =
    { get = .w1
    , set = \comps world -> { world | w1 = comps }
    }


specW2 =
    { get = .w2
    , set = \comps world -> { world | w2 = comps }
    }


specVec2 =
    { get = .vec2
    , set = \comps world -> { world | vec2 = comps }
    }


specVec3 =
    { get = .vec3
    , set = \comps world -> { world | vec3 = comps }
    }


specVec4 =
    { get = .vec4
    , set = \comps world -> { world | vec4 = comps }
    }


cursor spec2 spec1 =
    { get = spec2.get >> spec1.get
    , set =
        \comp world ->
            spec2.set (spec1.set comp (spec2.get world)) world
    }
