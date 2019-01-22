module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Defaults exposing (default)
import Environment exposing (Environment)
import Http
import Json.Decode as Json
import ResourceManager exposing (RemoteData(..))
import Task
import WebGL
import World exposing (World)


main : Program Json.Value Model Message
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions =
            \model ->
                case model.loader of
                    Success world ->
                        [ Environment.subscriptions model.env |> Sub.map Environment
                        , Browser.onAnimationFrameDelta Frame
                        ]
                            |> Sub.batch

                    _ ->
                        Environment.subscriptions model.env |> Sub.map Environment
        }


init : Json.Value -> ( Model, Cmd Message )
init flags =
    let
        ( env, envMsg ) =
            Environment.init flags

        ( loader, loaderMsg ) =
            ResourceManager.init World.init Task.fail flags
    in
    ( { env = env
      , loader = loader
      }
    , Cmd.batch
        [ envMsg |> Cmd.map Environment
        , loaderMsg |> Cmd.map Loader
        ]
    )


type alias Model =
    { env : Environment
    , loader : RemoteData Http.Error World
    }


type Message
    = Environment Environment.Message
    | Loader (ResourceManager.RemoteData Http.Error World)
    | Frame Float


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case ( msg, model.loader ) of
        ( Frame delta, Success world ) ->
            ( { model
                | loader =
                    Success (World.update delta world)
              }
            , Cmd.none
            )

        ( Environment income, _ ) ->
            ( { model | env = Environment.update income model.env }, Cmd.none )

        ( Loader income, _ ) ->
            ( { model | loader = income }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Document Message
view model =
    case model.loader of
        Loading ->
            { title = "Loading"
            , body =
                [ WebGL.toHtmlWith default.webGLOption (Environment.style model.env) []
                ]
            }

        Failure e ->
            { title = "Failure"
            , body =
                [ WebGL.toHtmlWith default.webGLOption (Environment.style model.env) []
                ]
            }

        Success world ->
            { title = "Success"
            , body =
                [ World.view model.env world
                    |> WebGL.toHtmlWith default.webGLOption (Environment.style model.env)
                ]
            }
