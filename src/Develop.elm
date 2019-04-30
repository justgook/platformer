port module Develop exposing (World, document)

--import World.Component.Layer as Layer exposing (Layer)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Defaults exposing (default)
import Environment exposing (Environment)
import Error exposing (Error(..))
import Json.Decode as Decode
import Logic.GameFlow as Flow
import ResourceTask exposing (ResourceTask)
import WebGL
import World
import World.Create


type alias World world =
    World.World world


type alias Model world =
    { tmpEnv : Environment
    , resource : world
    }


type Message world
    = Environment Environment.Message
    | Frame Float
    | Subscription ( Flow.Model { env : Environment }, world )
    | Resource (Result Error (World.World world))



--    | Event (world -> world)


port start : () -> Cmd msg


document { world, system, read, view, subscriptions } =
    Browser.document
        { init = init_ world read
        , view = view_ view
        , update = update system
        , subscriptions =
            \model_ ->
                case model_.resource of
                    Ok (World.World world1 world2) ->
                        [ Environment.subscriptions world1.env |> Sub.map Environment
                        , Browser.onAnimationFrameDelta Frame
                        , subscriptions ( world1, world2 ) |> Sub.map Subscription
                        ]
                            |> Sub.batch

                    _ ->
                        Environment.subscriptions model_.tmpEnv |> Sub.map Environment
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
    ( { tmpEnv = env
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

        ( Environment info, Ok (World.World common ecs) ) ->
            ( ( { common | env = Environment.update info common.env }, ecs ) |> wrap model, Cmd.none )

        ( Environment info, _ ) ->
            ( { model | tmpEnv = Environment.update info model.tmpEnv }, Cmd.none )

        ( Resource (Ok (World.World common ecs)), _ ) ->
            ( ( { common | env = model.tmpEnv }, ecs ) |> wrap model, start () )

        ( Resource resource, _ ) ->
            ( { model | resource = resource }, Cmd.none )

        _ ->
            ( model, Cmd.none )


wrap m data =
    { m | resource = Ok (data |> (\( a, b ) -> World.World a b)) }


view_ render model =
    case model.resource of
        Ok (World.World common ecs) ->
            { title = "Success"
            , body =
                render (Environment.style common.env) common ecs
            }

        Err (Error 0 t) ->
            { title = t
            , body =
                [ WebGL.toHtmlWith default.webGLOption (Environment.style model.tmpEnv) []
                ]
            }

        Err (Error code e) ->
            { title = "Failure:" ++ String.fromInt code
            , body =
                []
            }
