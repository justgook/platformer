module Logic.Template.System.VelocityPosition exposing (system)

import AltMath.Vector2 as Vec2
import Logic.Component
import Logic.System exposing (System)
import Logic.Template.Component.Position exposing (Position)
import Logic.Template.Component.Velocity exposing (Velocity)


system : Logic.Component.Spec Velocity world -> Logic.Component.Spec Position world -> System world
system =
    Logic.System.step2
        (\( velocity, _ ) ( pos, setPos ) -> setPos (Vec2.add velocity pos))
