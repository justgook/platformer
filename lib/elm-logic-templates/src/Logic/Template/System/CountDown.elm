module Logic.Template.System.CountDown exposing (system)

import Array
import Logic.Component
import Logic.System exposing (System, applyIf)


system : (Int -> world -> world) -> Logic.Component.Spec number world -> world -> world
system end spec world =
    let
        combined =
            { a = spec.get world
            , b = []
            }

        setA i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        result =
            Logic.System.indexedFoldl
                (\i num acc ->
                    let
                        newNum =
                            num - 1
                    in
                    if newNum > 0 then
                        setA i newNum acc

                    else
                        { acc | b = i :: acc.b }
                )
                combined.a
                combined
    in
    world
        |> applyIf (result.a /= combined.a) (spec.set result.a)
        |> applyIf (result.b /= combined.b) (\w -> List.foldl end w result.b)


aSpec =
    { get = .a
    , set = \comps world -> { world | a = comps }
    }


bSpec =
    { get = .b
    , set = \comps world -> { world | b = comps }
    }
