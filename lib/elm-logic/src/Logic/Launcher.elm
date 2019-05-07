port module Logic.Launcher exposing (Launcher, World, document)

--import World.Component.Layer as Layer exposing (Layer)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Error exposing (Error(..))
import Json.Decode as Json
import Logic.Environment as Environment exposing (Environment)
import Logic.GameFlow
import Task exposing (Task)
import VirtualDom


type alias World world =
    Logic.GameFlow.Model { world | env : Environment }


type Message world
    = Environment Environment.Message
    | Frame Float
    | Subscription (World world)
    | Resource (Model world)
    | Event (World world -> World world)


type Model world
    = Loading Environment
    | Succeed (World world)
    | Fail Error


port start : () -> Cmd msg


type alias Launcher world =
    Program Json.Value (Model world) (Message world)


document :
    { init : Json.Value -> Task.Task Error.Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> World world
    , view :
        List (VirtualDom.Attribute msg)
        -> World world
        -> List (VirtualDom.Node (World world -> World world))
    }
    -> Launcher world
document { init, update, view, subscriptions } =
    Browser.document
        { init = init_ init
        , view = view_ view
        , update = update_ update
        , subscriptions = subscriptions_ subscriptions
        }


init_ :
    (Json.Value -> Task.Task Error.Error (World world))
    -> Json.Value
    -> ( Model world1, Cmd (Message world) )
init_ init flags =
    let
        ( env, envMsg ) =
            Environment.init flags

        initTask =
            init flags
                |> Task.attempt
                    (\r ->
                        case r of
                            Ok a ->
                                Resource (Succeed a)

                            Err e ->
                                Resource (Fail e)
                    )
    in
    ( Loading env
    , Cmd.batch
        [ envMsg |> Cmd.map Environment
        , initTask
        ]
    )


subscriptions_ :
    (World world1 -> Sub (World world))
    -> Model world1
    -> Sub (Message world)
subscriptions_ subscriptions =
    \model_ ->
        case model_ of
            Succeed world ->
                [ Sub.map Environment Environment.subscriptions
                , Browser.onAnimationFrameDelta Frame
                , subscriptions world |> Sub.map Subscription
                ]
                    |> Sub.batch

            Loading _ ->
                Sub.map Environment Environment.subscriptions

            Fail _ ->
                Sub.none


update_ :
    (World world -> World world)
    -> Message world
    -> Model world
    -> ( Model world, Cmd msg )
update_ update msg model =
    case ( msg, model ) of
        ( Frame delta, Succeed world ) ->
            let
                newWorld =
                    Logic.GameFlow.update update delta world
            in
            ( Succeed newWorld, Cmd.none )

        ( Subscription custom, _ ) ->
            ( Succeed custom, Cmd.none )

        ( Event f, Succeed world ) ->
            ( Succeed (f world), Cmd.none )

        ( Environment info, Loading tmpEnv ) ->
            ( Loading (Environment.update info tmpEnv), Cmd.none )

        ( Environment info, Succeed world ) ->
            ( Succeed { world | env = Environment.update info world.env }, Cmd.none )

        ( Resource (Succeed world), Loading tmpEnv ) ->
            ( Succeed { world | env = tmpEnv }, start () )

        ( Resource (Succeed world), Succeed _ ) ->
            ( Succeed world, start () )

        _ ->
            ( model, Cmd.none )


view_ :
    (List (VirtualDom.Attribute msg)
     -> World world
     -> List (VirtualDom.Node (World world -> World world))
    )
    -> Model world
    ->
        { body : List (VirtualDom.Node (Message world))
        , title : String
        }
view_ view model =
    case model of
        Succeed world ->
            { title = "Success"
            , body =
                view (Environment.style world.env) world
                    |> List.map (VirtualDom.map Event)
            }

        Loading _ ->
            { title = "Loading", body = [] }

        Fail (Error code e) ->
            { title = "Failure:" ++ String.fromInt code
            , body =
                []
            }
