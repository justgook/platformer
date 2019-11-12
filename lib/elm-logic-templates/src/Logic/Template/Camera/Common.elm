module Logic.Template.Camera.Common exposing (LegacyAny, LegacyCamera, LegacyWithId)

import AltMath.Vector2 exposing (Vec2)


type alias LegacyAny a =
    { a
        | viewportOffset : Vec2
    }


type alias LegacyCamera =
    LegacyAny {}


type alias LegacyWithId a =
    LegacyAny { a | id : Int }
