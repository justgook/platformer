module Logic.Template.Component.AI exposing (AI, empty, spec)

import Logic.Component
import Logic.System


type alias AI =
    { start : Int
    , x : Options
    , y : Options
    }


type alias Options =
    { max : Float
    , min : Float
    , speed : Float
    , start : Float
    }


spec : Logic.Component.Spec AI { world | ai : Logic.Component.Set AI }
spec =
    { get = .ai
    , set = \comps world -> { world | ai = comps }
    }


empty : Logic.Component.Set AI
empty =
    Logic.Component.empty
