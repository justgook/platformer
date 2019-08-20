module Logic.Template.Component.Position exposing (Position, empty, spec)

import AltMath.Vector2 exposing (Vec2)
import Logic.Component exposing (Set, Spec)


type alias Position =
    AltMath.Vector2.Vec2


spec : Spec Position { world | position : Set Position }
spec =
    { get = .position
    , set = \comps world -> { world | position = comps }
    }


empty : Set Position
empty =
    Logic.Component.empty
