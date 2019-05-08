module Logic.Asset.Camera.Common exposing (Any, Camera, WithId)

import AltMath.Vector2 as Vec2 exposing (Vec2)


type alias Any a =
    { a
        | pixelsPerUnit : Float
        , viewportOffset : Vec2
    }


type alias Camera =
    Any {}


type alias WithId a =
    Any { a | id : Int }
