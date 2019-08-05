module Logic.Launcher exposing
    ( document, task, worker
    , Message, Document, Error(..), Launcher, World
    , inline
    )

{-|

@docs document, task, worker
@docs Message, Document, Error, Launcher, World
@docs inline

-}

import Browser exposing (Document, UrlRequest(..))
import Browser.Events as Browser
import Html exposing (Html)
import Logic.GameFlow
import Task


{-| Error type to hold all error of game init
-}
type Error
    = Error Int String


{-| just alias to `Logic.GameFlow.Model world`
-}
type alias World world =
    Logic.GameFlow.Model world


{-| -}
type Message world
    = Frame Float
    | Subscription (World world)
    | Resource (Model world)
    | Event (World world -> World world)


type Model world
    = Loading
    | Succeed (World world)
    | Fail Error


{-| -}
type alias Launcher flags world =
    Program flags (Model world) (Message world)


{-| difference from `Browser.document`:

1.  `init` takes as argument flags and returns Task, that results in world or fail (90% of games any way need get some data to start, images, level data, connection, etc.)
2.  `subscriptions` instead of returning msg - should return new `World`
3.  `update` have no `Msg` input
4.  `view` instead of `Msg` event have to return function

-}
type alias Document flags world =
    { init : flags -> Task.Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> ( World world, Cmd (Message world) )
    , view : World world -> List (Html (World world -> World world))
    }


{-| Main entry point, but have few difference from `Browser.document`
-}
document : Document flags (World world) -> Launcher flags (World world)
document { init, update, view, subscriptions } =
    Browser.document
        { init = init_ init
        , view = view_ view
        , update = update_ update
        , subscriptions = subscriptions_ subscriptions
        }


{-| Instead of creating game as separate application, you can inline it inside your own application
-}
inline :
    { a
        | update : World world -> ( World world, Cmd (Message world) )
        , view : world -> List (Html (World world -> World world))
        , subscriptions : world -> Sub (World world)
    }
    ->
        { view : world -> List (Html (Message world))
        , update : Message world -> World world -> ( World world, Cmd (Message world) )
        , subscriptions : world -> Sub (Message world)
        }
inline { update, view, subscriptions } =
    { view = viewSucceed_ view
    , update = updateSucceed_ update
    , subscriptions = subscriptionsSucceed_ subscriptions
    }


{-| Main entry point, but have few difference from `Platform.worker`
-}
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


{-| Helper function, that allow convert `Task` into Cmd - for loading new `World` after `init`
-}
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


subscriptionsSucceed_ subscriptions world =
    [ Browser.onAnimationFrameDelta Frame
    , subscriptions world |> Sub.map Subscription
    ]
        |> Sub.batch


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
            ( Succeed (f world), Cmd.none )

        ( Resource (Succeed world), Loading ) ->
            ( Succeed world, Cmd.none )

        ( Resource resource, _ ) ->
            ( resource, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateSucceed_ update msg world =
    case msg of
        Frame delta ->
            Logic.GameFlow.updateWith (updateWrapper update) delta ( world, [] )
                |> Tuple.mapSecond Cmd.batch

        Event f ->
            ( f world, Cmd.none )

        Subscription custom ->
            ( custom, Cmd.none )

        Resource (Succeed resource) ->
            ( resource, Cmd.none )

        Resource _ ->
            ( world, Cmd.none )


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
                view world |> List.map (Html.map Event)
            }

        Loading ->
            { title = "Loading", body = [] }

        Fail (Error code e) ->
            { title = "Failure:" ++ String.fromInt code ++ "(" ++ e ++ ")"
            , body =
                []
            }


viewSucceed_ : (world -> List (Html (World world -> World world))) -> world -> List (Html (Message world))
viewSucceed_ view world =
    view world |> List.map (Html.map Event)
