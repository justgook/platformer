module Logic.Template.Camera.PositionLocking exposing (lock, xClamp, xLockLegacy, yLockLegacy)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Camera.Common exposing (LegacyAny)
import Logic.Template.Component.LevelSize exposing (LevelSize)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Math.Vector2



--lock : AltMath.Vector2.Vec2 -> LegacyAny a -> LegacyAny a


lock target cam =
    { cam | viewportOffset = target }



--xLockLegacy : AltMath.Vector2.Vec2 -> LegacyAny a -> LegacyAny a
--xLockLegacy : { a | x : b } -> { c | viewportOffset : { x : b, y : d } } -> { c | viewportOffset : { x : b, y : d } }


xLockLegacy target cam =
    { cam | viewportOffset = Vec2.setX (Vec2.getX target) cam.viewportOffset }



--yLockLegacy : AltMath.Vector2.Vec2 -> LegacyAny a -> LegacyAny a


yLockLegacy target cam =
    { cam | viewportOffset = { x = cam.viewportOffset.x, y = target.y } }


xClamp : Singleton.Spec LevelSize world -> Singleton.Spec RenderInfo world -> Vec2 -> world -> world
xClamp levelSizeSpec renderSpec target world =
    Singleton.update renderSpec
        (\render ->
            let
                newX =
                    clamp 0
                        (toFloat (levelSizeSpec.get world).width - render.virtualScreen.width)
                        (Vec2.getX target - render.virtualScreen.width * 0.5)

                newY =
                    clamp 0
                        (toFloat (levelSizeSpec.get world).height - render.virtualScreen.height)
                        (Vec2.getY target - render.virtualScreen.height * 0.5)

                newOffset =
                    Math.Vector2.vec2 newX newY

                --
                --                newOffset =
                --                    Math.Vector2.vec2 100 10
                newRenderInfo =
                    RenderInfo.setOffset newOffset render
            in
            newRenderInfo
        )
        world
