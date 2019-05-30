module Logic.Template.Component.TimeLine exposing (Frame, Simple, empty, emptyComp, get, spec)

import Logic.Component exposing (Set, Spec)
import Logic.Template.Internal exposing (Timeline)
import Math.Vector2 exposing (Vec2, vec2)


type alias Simple =
    { start : Int
    , timeline : Timeline Float
    , uMirror : Vec2 -- = vec2 0 0
    }


type alias Frame =
    Int


get : Frame -> Simple -> Float
get i l =
    l |> .timeline |> Logic.Template.Internal.get (i - l.start)


spec : Spec Simple { world | timelines : Set Simple }
spec =
    { get = .timelines
    , set = \comps world -> { world | timelines = comps }
    }


empty : Set Simple
empty =
    Logic.Component.empty


emptyComp : List Float -> Simple
emptyComp l =
    case l of
        x :: xs ->
            { start = 0
            , timeline = Logic.Template.Internal.timeline x xs
            , uMirror = vec2 0 0
            }

        [] ->
            { start = 0
            , timeline = Logic.Template.Internal.timeline 0 []
            , uMirror = vec2 0 0
            }
