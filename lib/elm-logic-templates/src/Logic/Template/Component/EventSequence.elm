module Logic.Template.Component.EventSequence exposing (EventSequence(..), add, apply, empty, fromList, spec, toList)

import Logic.Component.Singleton as Singleton
import Logic.Launcher as Launcher


type EventSequence e
    = Empty
    | Sequence
        { nextFireFrame : Int
        , next : e
        , rest : List ( Int, e )
        }


toList : EventSequence e -> List ( Int, e )
toList sequence =
    case sequence of
        Empty ->
            []

        Sequence e ->
            ( e.nextFireFrame, e.next ) :: e.rest


fromList : List ( Int, e ) -> EventSequence e
fromList l =
    case l of
        ( frame, item ) :: rest ->
            Sequence
                { nextFireFrame = frame
                , next = item
                , rest = rest
                }

        [] ->
            Empty


add ( nextFireFrame_, next_ ) eventSequence =
    case eventSequence of
        Empty ->
            Sequence
                { nextFireFrame = nextFireFrame_
                , next = next_
                , rest = []
                }

        Sequence { rest, nextFireFrame, next } ->
            List.sortBy Tuple.first (( nextFireFrame_, next_ ) :: ( nextFireFrame, next ) :: rest) |> setNext


apply : Singleton.Spec (EventSequence e) (Launcher.World world) -> (e -> Launcher.World world -> Launcher.World world) -> Launcher.World world -> Launcher.World world
apply spec_ f world =
    let
        events =
            spec_.get world
    in
    case events of
        Empty ->
            world

        Sequence info ->
            if world.frame >= info.nextFireFrame then
                f info.next <| spec_.set (setNext info.rest) world

            else
                world


setNext l =
    case l of
        ( nextFireFrame, next ) :: rest ->
            Sequence
                { nextFireFrame = nextFireFrame
                , next = next
                , rest = rest
                }

        [] ->
            Empty


empty : EventSequence e
empty =
    Empty


spec : Singleton.Spec (EventSequence e) { world | events : EventSequence e }
spec =
    { get = .events
    , set = \comps world -> { world | events = comps }
    }
