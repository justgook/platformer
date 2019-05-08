module Logic.Asset.Camera.PositionLocking exposing (lock, xLock, yLock)

import AltMath.Vector2 exposing (Vec2)
import Logic.Asset.Camera.Common exposing (Any)


lock : Vec2 -> Any a -> Any a
lock target cam =
    { cam | viewportOffset = target }


xLock : Vec2 -> Any a -> Any a
xLock target cam =
    { cam | viewportOffset = { x = target.x, y = cam.viewportOffset.y } }


yLock : Vec2 -> Any a -> Any a
yLock target cam =
    { cam | viewportOffset = { x = cam.viewportOffset.x, y = target.y } }
