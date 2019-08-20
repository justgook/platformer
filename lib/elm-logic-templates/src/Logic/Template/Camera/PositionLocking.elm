module Logic.Template.Camera.PositionLocking exposing (lock, xClamp, xLockLegacy, yLockLegacy)

import AltMath.Vector2
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Camera.Common exposing (LegacyAny)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Math.Vector2


lock : AltMath.Vector2.Vec2 -> LegacyAny a -> LegacyAny a
lock target cam =
    { cam | viewportOffset = target }


xLockLegacy : AltMath.Vector2.Vec2 -> LegacyAny a -> LegacyAny a
xLockLegacy target cam =
    { cam | viewportOffset = { x = target.x, y = cam.viewportOffset.y } }


yLockLegacy : AltMath.Vector2.Vec2 -> LegacyAny a -> LegacyAny a
yLockLegacy target cam =
    { cam | viewportOffset = { x = cam.viewportOffset.x, y = target.y } }


xClamp : Singleton.Spec RenderInfo world -> { x : Float, y : Float } -> world -> world
xClamp renderSpec target =
    Singleton.update renderSpec
        (\render ->
            let
                newX =
                    clamp 0
                        (toFloat render.levelSize.width - render.virtualScreen.width)
                        (target.x - render.virtualScreen.width * 0.5)

                newOffset =
                    Math.Vector2.setX newX render.offset

                newRenderInfo =
                    RenderInfo.setOffset newOffset render
            in
            newRenderInfo
        )
