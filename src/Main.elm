module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
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
                Environment.subscriptions model.env
                    |> Sub.map Environment
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


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Environment income ->
            ( { model | env = Environment.update income model.env }, Cmd.none )

        Loader income ->
            ( { model | loader = income }, Cmd.none )


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
