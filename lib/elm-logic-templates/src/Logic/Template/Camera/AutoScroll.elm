module Logic.Template.Camera.AutoScroll exposing (step)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Template.Camera.Common exposing (LegacyAny, LegacyCamera, LegacyWithId)


step : Vec2 -> LegacyAny a -> LegacyAny a
step speed cam =
    { cam | viewportOffset = Vec2.add cam.viewportOffset speed }
