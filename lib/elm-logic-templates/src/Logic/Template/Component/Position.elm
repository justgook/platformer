module Logic.Template.Component.Position exposing (Position, empty, spec)

import AltMath.Vector2 exposing (Vec2)
import Logic.Component as Component


type alias Position =
    AltMath.Vector2.Vec2


spec : Component.Spec2 Position { world1 | position : Component.Set Position } { world2 | position : Component.Set Position }
spec =
    { get = .position
    , set = \comps world -> { world | position = comps }
    }


empty : Component.Set Position
empty =
    Component.empty
