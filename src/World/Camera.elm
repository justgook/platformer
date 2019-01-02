module World.Camera exposing (Camera, init)

import Defaults exposing (default)
import Math.Vector2 exposing (Vec2)
import Tiled.Level as Level exposing (Level)
import Tiled.Util exposing (levelProps)


type alias Camera =
    { pixelsPerUnit : Float
    , viewportOffset : Vec2
    }


init : Level -> Camera
init level =
    levelProps level
        |> (\prop ->
                { pixelsPerUnit = prop.float "pixelsPerUnit" default.pixelsPerUnit
                , viewportOffset = default.viewportOffset
                }
           )
