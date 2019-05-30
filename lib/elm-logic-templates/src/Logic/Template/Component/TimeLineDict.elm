module Logic.Template.Component.TimeLineDict exposing (AnimationId, TimeLineDict, empty, spec)

import Dict exposing (Dict)
import Logic.Component exposing (Set, Spec)
import Logic.Template.Component.TimeLine as TimeLine


type alias Current =
    AnimationId


type alias AnimationId =
    ( String, Int )


type alias TimeLineDict =
    ( Current, Dict AnimationId TimeLine.Simple )


spec : Spec TimeLineDict { world | animations2 : Set TimeLineDict }
spec =
    { get = .animations2
    , set = \comps world -> { world | animations2 = comps }
    }


empty =
    Logic.Component.empty
