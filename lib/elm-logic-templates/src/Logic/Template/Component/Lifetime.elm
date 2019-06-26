module Logic.Template.Component.Lifetime exposing (Lifetime, empty, spec)

import Logic.Component


type alias Lifetime =
    Int


spec : Logic.Component.Spec Lifetime { world | lifetime : Logic.Component.Set Lifetime }
spec =
    { get = .lifetime
    , set = \comps world -> { world | lifetime = comps }
    }


empty : Logic.Component.Set Lifetime
empty =
    Logic.Component.empty
