port module Logic.Launcher exposing (Error(..), Launcher, World, document, worker)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Logic.GameFlow
import Task exposing (Task)
import VirtualDom


type Error
    = Error Int String


type alias World world =
    Logic.GameFlow.Model world


type Message world
    = Frame Float
    | Subscription (World world)
    | Resource (Model world)
    | Event (World world -> World world)


type Model world
    = Loading
    | Succeed (World world)
    | Fail Error


port start : () -> Cmd msg


type alias Launcher flags world =
    Program flags (Model world) (Message world)


document :
    { init : flags -> Task.Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> World world
    , view :
        World world
        -> List (VirtualDom.Node (World world -> World world))
    }
    -> Launcher flags world
document { init, update, view, subscriptions } =
    Browser.document
        { init = init_ init
        , view = view_ view
        , update = update_ update
        , subscriptions = subscriptions_ subscriptions
        }


worker :
    { init : flags -> Task.Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> World world
    }
    -> Launcher flags world
worker { init, update, subscriptions } =
    Platform.worker
        { init = init_ init
        , update = update_ update
        , subscriptions = subscriptions_ subscriptions
        }


init_ :
    (flags -> Task.Task Error (World world))
    -> flags
    -> ( Model world1, Cmd (Message world) )
init_ init flags =
    let
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
    ( Loading
    , initTask
    )


subscriptions_ :
    (World world1 -> Sub (World world))
    -> Model world1
    -> Sub (Message world)
subscriptions_ subscriptions model_ =
    case model_ of
        Succeed world ->
            [ Browser.onAnimationFrameDelta Frame
            , subscriptions world |> Sub.map Subscription
            ]
                |> Sub.batch

        Loading ->
            Sub.none

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

        ( Resource (Succeed world), Loading ) ->
            ( Succeed world, start () )

        ( Resource resource, _ ) ->
            ( resource, Cmd.none )

        _ ->
            ( model, Cmd.none )


view_ :
    (World world
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
                view world
                    |> List.map (VirtualDom.map Event)
            }

        Loading ->
            { title = "Loading", body = [] }

        Fail (Error code e) ->
            { title = "Failure:" ++ String.fromInt code
            , body =
                []
            }
