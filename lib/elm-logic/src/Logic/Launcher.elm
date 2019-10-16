module Logic.Launcher exposing
    ( document, documentWith, worker, workerWith
    , inline
    , async, sync
    , Document, DocumentWith, Error(..), Launcher, World, Message
    )

{-|

@docs document, documentWith, worker, workerWith
@docs inline
@docs async, sync
@docs Document, DocumentWith, Error, Launcher, World, Message

-}

import Browser
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
    | Subscription ( world, Cmd (Message world) )
    | Resource (Model world)
    | Event (world -> world)


type Model world
    = Loading
    | Succeed world
    | Fail Error


{-| -}
type alias Launcher flags world =
    Program flags (Model (World world)) (Message (World world))


{-| -}
type alias Document flags world =
    { init : flags -> Task.Task Error (World world)
    , update : World world -> World world
    , view : World world -> List (Html.Html (World world -> World world))
    , subscriptions : World world -> Sub (World world)
    }


{-| Same as `document` but `subscriptions` and `update` returns also `Cmd` - useful for `ports`
-}
type alias DocumentWith flags world =
    { init : flags -> ( Task.Task Error (World world), Cmd (Message (World world)) )
    , subscriptions : World world -> Sub ( World world, Cmd (Message (World world)) )
    , update : World world -> ( World world, Cmd (Message (World world)) )
    , view : World world -> List (Html.Html (World world -> World world))
    }


{-| Main entry point, but have few difference from `Browser.document`:

1.  `init` takes as argument flags and returns Task, that results in world or fail (90% of games any way need get some data to start, images, level data, connection, etc.)
2.  `subscriptions` instead of returning msg - should return new `World`
3.  `update` have no `Msg` input and returns just `World`
4.  `view` instead of `Msg` event have to return function

-}
document : Document flags world -> Launcher flags world
document { init, update, view, subscriptions } =
    let
        aaa delta world =
            ( Logic.GameFlow.update update delta world
                |> Succeed
            , Cmd.none
            )
    in
    Browser.document
        { init = init_ init
        , view = view_ view
        , update = update_ aaa
        , subscriptions = subscriptions_ (\w -> Subscription ( w, Cmd.none )) subscriptions
        }


{-| Same as [`Launcher.document`](#document) but `init`, `subscriptions` and `update` returns also `Cmd` (useful for `ports`)
-}
documentWith : DocumentWith flags world -> Launcher flags world
documentWith { init, update, view, subscriptions } =
    let
        aaa delta world =
            Logic.GameFlow.updateWith (updateWrapper update) delta ( world, [] )
                |> Tuple.mapBoth Succeed Cmd.batch

        bbb flags =
            let
                ( a, b ) =
                    init flags
            in
            ( Loading
            , Cmd.batch [ b, load_ a ]
            )
    in
    Browser.document
        { init = bbb
        , view = view_ view
        , update = update_ aaa
        , subscriptions = subscriptions_ Subscription subscriptions
        }


{-| Instead of creating game as separate application, you can inline it inside your own application
-}
inline :
    { aa
        | update : World a -> World a
        , view : c -> List (Html.Html (world -> world))
        , subscriptions : b -> Sub world1
    }
    ->
        { subscriptions : b -> Sub (Message world1)
        , update :
            Message (World a)
            -> World a
            -> ( World a, Cmd (Message (World a)) )
        , view : c -> List (Html.Html (Message world))
        }
inline { update, view, subscriptions } =
    { view = viewSucceed_ view
    , update = updateSucceed_ update
    , subscriptions = subscriptionsSucceed_ subscriptions
    }


{-| Main entry point, similar to `Platform.worker`
-}
worker :
    { init : flags -> Task.Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> World world
    }
    -> Launcher flags world
worker { init, update, subscriptions } =
    let
        aaa delta world =
            ( Logic.GameFlow.update update delta world
                |> Succeed
            , Cmd.none
            )
    in
    Platform.worker
        { init = init_ init
        , update = update_ aaa
        , subscriptions = subscriptions_ (\w -> Subscription ( w, Cmd.none )) subscriptions
        }


{-| Same as [`Launcher.worker`](#worker), but `init`, `subscriptions` and `update` returns also `Cmd` (useful for `ports`)
-}
workerWith :
    { init : flags -> Task.Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update :
        World world
        -> ( World world, Cmd (Message (World world)) )
    }
    -> Launcher flags world
workerWith { init, update, subscriptions } =
    let
        aaa delta world =
            Logic.GameFlow.updateWith (updateWrapper update) delta ( world, [] )
                |> Tuple.mapBoth Succeed Cmd.batch
    in
    Platform.worker
        { init = init_ init
        , update = update_ aaa
        , subscriptions = subscriptions_ (\w -> Subscription ( w, Cmd.none )) subscriptions
        }


{-| Helper function, that allow convert `Task` into Cmd - for loading new `World` after `init`
-}
async : (Result x a -> world -> world) -> Task.Task x a -> Cmd (Message world)
async f t =
    Task.attempt (f >> Event) t


{-| Wrapper for messages, when using libs like `Random`

    Random.generate (\seed -> Launcher.event (\w -> { w | seed = seed })) Random.independentSeed

-}
sync : (world -> world) -> Message world
sync =
    Event


init_ : (flags -> Task.Task Error world) -> flags -> ( Model world, Cmd (Message world) )
init_ init flags =
    ( Loading
    , load_ (init flags)
    )


load_ : Task.Task Error world -> Cmd (Message world)
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


subscriptions_ : (a -> Message world) -> (b -> Sub a) -> Model b -> Sub (Message world)
subscriptions_ mapper subscriptions model_ =
    case model_ of
        Succeed world ->
            [ Browser.onAnimationFrameDelta Frame
            , subscriptions world
                |> Sub.map mapper
            ]
                |> Sub.batch

        Loading ->
            Sub.none

        Fail _ ->
            Sub.none


subscriptionsSucceed_ : (b -> Sub a) -> b -> Sub (Message a)
subscriptionsSucceed_ subscriptions world =
    [ Browser.onAnimationFrameDelta Frame
    , subscriptions world
        |> Sub.map (\w -> Subscription ( w, Cmd.none ))
    ]
        |> Sub.batch


update_ :
    (Float -> world -> ( Model world, Cmd (Message world) ))
    -> Message world
    -> Model world
    -> ( Model world, Cmd (Message world) )
update_ update msg model =
    case ( msg, model ) of
        ( Frame delta, Succeed world ) ->
            update delta world

        ( Subscription ( custom, cmd ), _ ) ->
            ( Succeed custom, cmd )

        ( Event f, Succeed world ) ->
            ( Succeed (f world), Cmd.none )

        ( Resource (Succeed world), Loading ) ->
            ( Succeed world, Cmd.none )

        ( Resource resource, _ ) ->
            ( resource, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateSucceed_ :
    (World world -> World world)
    -> Message (World world)
    -> World world
    -> ( World world, Cmd (Message (World world)) )
updateSucceed_ update msg world =
    case msg of
        Frame delta ->
            ( Logic.GameFlow.update update delta world, Cmd.none )

        Event f ->
            ( f world, Cmd.none )

        Subscription ( custom, cmd ) ->
            ( custom, cmd )

        Resource (Succeed resource) ->
            ( resource, Cmd.none )

        Resource _ ->
            ( world, Cmd.none )


updateWrapper update ( w, cmd ) =
    Tuple.mapSecond (\a -> a :: cmd) (update w)


view_ : (world -> List (Html (world -> world))) -> Model world -> Browser.Document (Message world)
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


viewSucceed_ : (b -> List (Html (world -> world))) -> b -> List (Html (Message world))
viewSucceed_ view world =
    view world |> List.map (Html.map Event)
