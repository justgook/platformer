module Logic.Launcher exposing (Document, Error(..), Launcher, World, document, task, worker)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Logic.GameFlow
import Task exposing (Task)
import Html exposing (Html)


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



type alias Launcher flags world =
    Program flags (Model world) (Message world)


type alias Document flags world =
    { init : flags -> Task.Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> ( World world, Cmd (Message world) )
    , view : World world -> List (Html (World world -> World world))
    }


document : Document flags world -> Launcher flags world
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
    , update : World world -> ( World world, Cmd (Message world) )
    }
    -> Launcher flags world
worker { init, update, subscriptions } =
    Platform.worker
        { init = init_ init
        , update = update_ update
        , subscriptions = subscriptions_ subscriptions
        }


task : (Result x a -> World world -> World world) -> Task.Task x a -> Cmd (Message world)
task f t =
    Task.attempt (f >> Event) t


init_ :
    (flags -> Task.Task Error (World world))
    -> flags
    -> ( Model world1, Cmd (Message world) )
init_ init flags =
    ( Loading
    , load_ (init flags)
    )


load_ : Task.Task Error (World world) -> Cmd (Message world)
load_ task_ =
    let
        initTask =
            task_
                |> Task.attempt
                    (\r ->
                        case r of
                            Ok a ->
                                Resource (Succeed a)

                            Err e ->
                                Resource (Fail e)
                    )
    in
    initTask


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
    (World world -> ( World world, Cmd (Message world) ))
    -> Message world
    -> Model world
    -> ( Model world, Cmd (Message world) )
update_ update msg model =
    case ( msg, model ) of
        ( Frame delta, Succeed world ) ->
            Logic.GameFlow.updateWith (updateWrapper update) delta ( world, [] ) |> Tuple.mapBoth Succeed Cmd.batch

        ( Subscription custom, _ ) ->
            ( Succeed custom, Cmd.none )

        ( Event f, Succeed world ) ->
            --            ( Succeed (f world |> Logic.GameFlow.update update 1), Cmd.none )
            ( Succeed (f world), Cmd.none )

        ( Resource (Succeed world), Loading ) ->
            ( Succeed world, start () )

        ( Resource resource, _ ) ->
            ( resource, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateWrapper :
    (World world -> ( World world, Cmd (Message world) ))
    -> ( World world, List (Cmd (Message world)) )
    -> ( World world, List (Cmd (Message world)) )
updateWrapper update ( w, cmd ) =
    Tuple.mapSecond (\a -> a :: cmd) (update w)


view_ :
    (World world
     -> List (Html (World world -> World world))
    )
    -> Model world
    ->
        { body : List (Html (Message world))
        , title : String
        }
view_ view model =
    case model of
        Succeed world ->
            { title = "Success"
            , body =
                view world
                    |> List.map (Html.map Event)
            }

        Loading ->
            { title = "Loading", body = [] }

        Fail (Error code e) ->
            { title = "Failure:" ++ String.fromInt code ++ "(" ++ e ++ ")"
            , body =
                []
            }
