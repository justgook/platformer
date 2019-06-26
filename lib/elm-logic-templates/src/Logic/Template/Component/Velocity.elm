module Logic.Template.Component.Velocity exposing (Velocity, empty, spec)

import AltMath.Vector2 exposing (Vec2)
import Logic.Component


type alias Velocity =
    Vec2


spec : Logic.Component.Spec Velocity { world | velocity : Logic.Component.Set Velocity }
spec =
    { get = .velocity
    , set = \comps world -> { world | velocity = comps }
    }


empty : Logic.Component.Set Velocity
empty =
    Logic.Component.empty
