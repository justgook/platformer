port module Game exposing (document)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Defaults exposing (default)
import Environment exposing (Environment)
import Http
import Json.Decode as Json
import Resource
import ResourceManager exposing (RemoteData(..))
import ResourceManager2
import Task
import Tiled
import Tiled.Level
import Tiled.Tileset
import Tiled.Util
import WebGL
import World exposing (World)


type alias Model =
    { env : Environment
    , loader : RemoteData Http.Error World

    -- , resource : ResourceManager2.Model Message
    }


port start : () -> Cmd msg


document : Program Json.Value Model Message
document =
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

        -- ( resourceModel, resourceCmd ) =
        --     ResourceManager2.init Resource
    in
    ( { env = env
      , loader = loader

      --   , resource = resourceModel
      }
    , Cmd.batch
        [ envMsg |> Cmd.map Environment
        , loaderMsg |> Cmd.map Loader

        -- , resourceCmd
        ]
    )


type Message
    = Environment Environment.Message
    | Loader (ResourceManager.RemoteData Http.Error World)
    | Frame Float



-- | Resource ResourceManager2.Message


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case ( msg, model.loader ) of
        ( Frame delta, Success world ) ->
            ( { model | loader = Success (World.update delta world) }
            , Cmd.none
            )

        ( Environment income, _ ) ->
            ( { model | env = Environment.update income model.env }, Cmd.none )

        ( Loader (Success income), _ ) ->
            ( { model | loader = Success income }, start () )

        ( Loader income, _ ) ->
            ( { model | loader = income }, Cmd.none )

        -- ( Resource income, _ ) ->
        --     let
        --         ( resource, cmd ) =
        --             Resource.update income model.resource
        --     in
        --     ( { model | resource = resource }, cmd )
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
