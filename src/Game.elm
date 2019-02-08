port module Game exposing (World, document)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Defaults exposing (default)
import Environment exposing (Environment)
import Http
import Json.Decode as Json
import Layer exposing (Layer)
import Logic.GameFlow as Flow
import Logic.System exposing (System)
import Resource
import ResourceManager exposing (RemoteData(..))
import ResourceManager2
import Task
import Tiled
import Tiled.Level
import Tiled.Tileset
import Tiled.Util
import WebGL
import World
import World.Camera as Camera exposing (Camera)
import World.Create
import World.Render


type alias World world obj =
    World.World world obj


type alias Model world obj =
    { env : Environment
    , loader : RemoteData Http.Error (World world obj)

    -- , resource : ResourceManager2.Model Message
    }


port start : () -> Cmd msg



-- document : Program Json.Value Model Message


document { init, system, read, view, subscriptions } =
    Browser.document
        { init = init_ init read
        , view = view_ view
        , update = update system
        , subscriptions =
            \model_ ->
                case model_.loader of
                    Success (World.World world1 world2) ->
                        [ Environment.subscriptions model_.env |> Sub.map Environment
                        , Browser.onAnimationFrameDelta Frame
                        , subscriptions ( world1, world2 ) |> Sub.map Subscription
                        ]
                            |> Sub.batch

                    _ ->
                        Environment.subscriptions model_.env |> Sub.map Environment
        }



-- init_ : Json.Value -> ( Model world, Cmd (Message world) )


init_ empty read flags =
    let
        ( env, envMsg ) =
            Environment.init flags

        ( loader, loaderMsg ) =
            ResourceManager.init
                (World.Create.init read
                    (\camera layers ->
                        World.World
                            { camera = camera
                            , layers = layers
                            , frame = 0
                            , runtime_ = 0
                            , flow = Flow.Running
                            }
                            empty
                    )
                )
                Task.fail
                flags

        -- ( resourceModel, resourceCmd ) =
        --     ResourceManager2.init Resource
    in
    ( { env = env
      , loader = loader
      }
    , Cmd.batch
        [ envMsg |> Cmd.map Environment
        , loaderMsg |> Cmd.map Loader
        ]
    )


type Message world obj
    = Environment Environment.Message
    | Loader (ResourceManager.RemoteData Http.Error (World world obj))
    | Frame Float
    | Subscription ( Flow.Model { camera : Camera, layers : List (Layer obj) }, world )


update system msg model =
    let
        wrap m data =
            { m | loader = Success (data |> (\( a, b ) -> World.World a b)) }
    in
    case ( msg, model.loader ) of
        ( Frame delta, Success (World.World world ecs) ) ->
            ( Flow.updateWith system delta ( world, ecs ) |> wrap model
            , Cmd.none
            )

        ( Subscription custom, Success (World.World world ecs) ) ->
            ( custom |> wrap model, Cmd.none )

        ( Environment info, _ ) ->
            ( { model | env = Environment.update info model.env }, Cmd.none )

        ( Loader (Success info), _ ) ->
            ( { model | loader = Success info }, start () )

        ( Loader info, _ ) ->
            ( { model | loader = info }, Cmd.none )

        -- ( Resource income, _ ) ->
        --     let
        --         ( resource, cmd ) =
        --             Resource.update income model.resource
        --     in
        --     ( { model | resource = resource }, cmd )
        _ ->
            ( model, Cmd.none )



-- view_ : Model world obj -> Document (Message world obj)


view_ objRender model =
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

        Success (World.World world ecs) ->
            { title = "Success"
            , body =
                [ World.Render.view objRender model.env world ecs
                    |> WebGL.toHtmlWith default.webGLOption
                        (Environment.style model.env)
                ]
            }
