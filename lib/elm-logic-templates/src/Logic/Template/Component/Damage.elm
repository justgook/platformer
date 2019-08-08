module Logic.Template.Component.Damage exposing (Damage, empty, spec)

import Logic.Component


type alias Damage =
    Int


spec : Logic.Component.Spec Damage { world | damage : Logic.Component.Set Damage }
spec =
    { get = .damage
    , set = \comps world -> { world | damage = comps }
    }


empty : Logic.Component.Set Damage
empty =
    Logic.Component.empty
