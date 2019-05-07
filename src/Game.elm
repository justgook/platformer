port module Game exposing (World, document)

--import World.Component.Layer as Layer exposing (Layer)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Environment exposing (Environment)
import Error exposing (Error(..))
import Json.Decode as Decode
import Logic.GameFlow as Flow
import Logic.Tiled.ResourceTask as ResourceTask exposing (ResourceTask)
import Task
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
    | NewModel (Resource__ world)


type Resource__ world
    = Loading Environment
    | Succeed world
    | Fail Error



--    | Event (world -> world)


port start : () -> Cmd msg


document { init, world, update, read, view, subscriptions } =
    Browser.document
        { init = init_ init world read
        , view = view_ view
        , update = update_ update
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


init_ init empty readers flags =
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

        initTask =
            init flags
                |> Task.attempt
                    (\r ->
                        case r of
                            Ok a ->
                                NewModel (Succeed a)

                            Err e ->
                                NewModel (Fail e)
                    )
    in
    ( { tmpEnv = env
      , resource = Err (Error 0 "Loading...")
      }
    , Cmd.batch
        [ envMsg |> Cmd.map Environment
        , ResourceTask.attempt Resource resourceTask
        , initTask
        ]
    )


update_ system msg model =
    case ( msg, model.resource ) of
        ( Frame delta, Ok (World.World world ecs) ) ->
            ( Flow.updateWith system delta ( world, ecs ) |> wrap model
            , Cmd.none
            )

        ( Subscription custom, Ok (World.World _ _) ) ->
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
            { title = t, body = [] }

        Err (Error code e) ->
            { title = "Failure:" ++ String.fromInt code
            , body =
                []
            }
