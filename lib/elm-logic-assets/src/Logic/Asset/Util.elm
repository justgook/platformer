module Logic.Asset.Util exposing (toRelative)

import AltMath.Vector2 exposing (Vec2)


toRelative : Float -> Vec2 -> Vec2
toRelative pixelsPerUnit { x, y } =
    { x = x / pixelsPerUnit
    , y = y / pixelsPerUnit
    }
