module Logic.Asset.Camera exposing (Any, Camera, WithId, empty, emptyWithId, spec)

import Defaults exposing (default)
import Math.Vector2 as Vec2 exposing (Vec2)


type alias Any a =
    { a
        | pixelsPerUnit : Float
        , viewportOffset : Vec2
    }


type alias Camera =
    Any {}


type alias WithId =
    Any { id : Int }


spec =
    { get = .camera
    , set = \comps world -> { world | camera = comps }
    }


empty =
    { pixelsPerUnit = default.pixelsPerUnit
    , viewportOffset = default.viewportOffset
    }


emptyWithId =
    { pixelsPerUnit = default.pixelsPerUnit
    , viewportOffset = default.viewportOffset
    , id = 0
    }
