module Shump.Debug exposing (..)

import Array
import Dict
import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.ShootEmUp as Game exposing (game)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo, setInitResize)
import Task


main : Launcher Value Game.World
main =
    --        Launcher.document { game | init = \_ -> Platformer.run "MazePlatformer.age.bin" }
    Launcher.document { game | init = debugInit }



--    Launcher.document { game | init = \_ -> Game.load "./space-shooter/demo.json" }
--
--
--debugInit : Value -> Task.Task Launcher.Error ShootEmUp.World


debugInit flags =
    Game.encode "./space-shooter/demo.json"
        |> Task.andThen
            (\( b, w ) ->
                Game.decode b
                    |> Task.andThen
                        (\w2 ->
                            let
                                _ =
                                    """( w.ammo |> Array.get 0 |> Maybe.withDefault Nothing |> Debug.log "w1"
                                    , w2.ammo |> Array.get 0 |> Maybe.withDefault Nothing |> Debug.log "w2"
                                    )"""
                            in
                            w
                                |> Task.succeed
                                |> setInitResize RenderInfo.spec
                        )
            )
