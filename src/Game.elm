port module Game exposing (World, document)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Defaults exposing (default)
import Environment exposing (Environment)
import Error exposing (Error(..))
import Json.Decode as Decode
import Layer exposing (Layer)
import Logic.GameFlow as Flow
import ResourceTask exposing (ResourceTask)
import WebGL
import World
import World.Camera exposing (Camera)
import World.Create
import World.Render


type alias World world =
    World.World world


type alias Model world =
    { env : Environment
    , resource : world
    }


type Message world defineMe
    = Environment Environment.Message
    | Frame Float
    | Subscription ( Flow.Model { camera : Camera, layers : List Layer }, world )
    | Resource (Result Error defineMe)


port start : () -> Cmd msg



-- document : Program Json.Value Model Message


document { world, system, read, view, subscriptions } =
    Browser.document
        { init = init_ world read
        , view = view_ view
        , update = update system
        , subscriptions =
            \model_ ->
                case model_.resource of
                    Ok (World.World world1 world2) ->
                        [ Environment.subscriptions model_.env |> Sub.map Environment
                        , Browser.onAnimationFrameDelta Frame
                        , subscriptions ( world1, world2 ) |> Sub.map Subscription
                        ]
                            |> Sub.batch

                    _ ->
                        Environment.subscriptions model_.env |> Sub.map Environment
        }


init_ empty readers flags =
    let
        ( env, envMsg ) =
            Environment.init flags

        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"

        resourceTask =
            ResourceTask.init
                |> ResourceTask.getLevel levelUrl
                |> ResourceTask.andThen (World.Create.init empty readers)
    in
    ( { env = env
      , resource = Err (Error 0 "Loading...")
      }
    , Cmd.batch
        [ envMsg |> Cmd.map Environment
        , ResourceTask.attempt Resource resourceTask
        ]
    )


update system msg model =
    case ( msg, model.resource ) of
        ( Frame delta, Ok (World.World world ecs) ) ->
            ( Flow.updateWith system delta ( world, ecs ) |> wrap model
            , Cmd.none
            )

        ( Subscription custom, Ok (World.World world ecs) ) ->
            ( custom |> wrap model, Cmd.none )

        ( Environment info, _ ) ->
            ( { model | env = Environment.update info model.env }, Cmd.none )

        ( Resource (Ok resource), _ ) ->
            ( { model | resource = Ok resource }, start () )

        ( Resource resource, _ ) ->
            ( { model | resource = resource }, Cmd.none )

        _ ->
            ( model, Cmd.none )


wrap m data =
    { m | resource = Ok (data |> (\( a, b ) -> World.World a b)) }


view_ objRender model =
    case model.resource of
        Ok (World.World world ecs) ->
            { title = "Success"
            , body =
                [ World.Render.view objRender model.env world ecs
                    |> WebGL.toHtmlWith default.webGLOption
                        (Environment.style model.env)
                ]
            }

        Err (Error 0 t) ->
            { title = t
            , body =
                [ WebGL.toHtmlWith default.webGLOption (Environment.style model.env) []
                ]
            }

        Err (Error code e) ->
            { title = "Failure:" ++ String.fromInt code
            , body =
                [ WebGL.toHtmlWith default.webGLOption (Environment.style model.env) []
                ]
            }
