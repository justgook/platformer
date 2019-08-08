module Logic.Template.Component.HitPoints exposing (HitPoints, empty, spec)

import Logic.Component


type alias HitPoints =
    Int


spec : Logic.Component.Spec HitPoints { world | hp : Logic.Component.Set HitPoints }
spec =
    { get = .hp
    , set = \comps world -> { world | hp = comps }
    }


empty : Logic.Component.Set HitPoints
empty =
    Logic.Component.empty
