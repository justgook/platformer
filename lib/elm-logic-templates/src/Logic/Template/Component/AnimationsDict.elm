module Logic.Template.Component.AnimationsDict exposing (AnimationId, TimeLineDict3, empty, spec)

import Dict exposing (Dict)
import Logic.Component as Component exposing (Set, Spec)


type alias Current =
    AnimationId


type alias AnimationId =
    ( String, Int )


type alias TimeLineDict3 a =
    ( Current, Dict AnimationId a )


spec : Spec (TimeLineDict3 a) { world | animations : Set (TimeLineDict3 a) }
spec =
    { get = .animations
    , set = \comps world -> { world | animations = comps }
    }


empty : Component.Set (TimeLineDict3 a)
empty =
    Component.empty
