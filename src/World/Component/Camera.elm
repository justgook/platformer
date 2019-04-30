module World.Component.Camera exposing (Any, Camera, Follow, empty, emptyWithId, spec)

import Defaults exposing (default)
import Dict
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Parser exposing ((|.), (|=), Parser)
import Set
import Tiled.Read exposing (Read(..), defaultRead)
import Tiled.Util exposing (levelProps)


type alias Any a =
    { a
        | pixelsPerUnit : Float
        , viewportOffset : Vec2
    }


type alias Camera =
    Any {}


type alias Follow =
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
