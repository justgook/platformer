module RPG.Debug exposing (..)

import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.TopDown as Game exposing (game)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo, setInitResize)
import Task


main : Launcher Value Game.World
main =
    Launcher.document { game | init = debugInit }


debugInit flags =
    Game.encode "./top-down-adventure/demo.json"
        |> Task.andThen
            (\( b, w ) ->
                Game.decode b
                    |> Task.andThen
                        (\w2 ->
                            w
                                |> Task.succeed
                                |> setInitResize RenderInfo.spec
                        )
            )
