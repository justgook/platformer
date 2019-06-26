module Logic.Template.System.AI exposing (system)

--https://gamedevelopment.tutsplus.com/series/understanding-steering-behaviors--gamedev-12732

import Logic.Component
import Logic.Launcher
import Logic.System exposing (System, applyIf)
import Logic.Template.Component.AI exposing (AI)
import Logic.Template.Component.Position exposing (Position)
import Logic.Template.Internal as Util



--system : Logic.Component.Spec AI (Logic.Launcher.World world) -> Logic.Component.Spec Position (Logic.Launcher.World world) -> System (Logic.Launcher.World world)


system render spec1 spec2 world =
    Logic.System.step2
        (\( { x, y, start }, _ ) ( pos, setPos ) acc ->
            let
                frameDiff =
                    world.frame - start

                { height, width } =
                    render.virtualScreen
            in
            acc
                |> setPos { x = mirror x width frameDiff, y = mirror y height frameDiff }
        )
        spec1
        spec2
        world


mirror opt ratio frame =
    let
        range =
            opt.max - opt.min

        stepCount =
            range / opt.speed

        offset =
            opt.start

        value_ =
            (toFloat frame / stepCount) + offset

        intPart =
            floor value_

        value =
            (value_ - toFloat intPart) |> applyIf (modBy 2 intPart == 1) ((-) 1)
    in
    (opt.min + value * range) |> (*) ratio



--        |> Debug.log "result"
