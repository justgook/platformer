module MazePlatformer.Debug exposing (..)

import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Component.SFX as AudioSprite
import Logic.Template.Game.Platformer as Game
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo, setInitResize)
import Task


game : Launcher.Document flags Game.World
game =
    Game.game


main : Launcher Value Game.World
main =
    --        Launcher.document { game | init = \_ -> Platformer.run "MazePlatformer.age.bin" }
    Launcher.document { game | init = debugInit }



--
--
--debugInit : Value -> Task.Task Launcher.Error ShootEmUp.World


debugInit flags =
    Game.encode "./platformer/demo.json"
        |> Task.andThen
            (\( b, w ) ->
                w
                    --                    |> AudioSprite.spawn AudioSprite.spec (AudioSprite.sound "Background")
                    --                    |> Debug.log "audiosprite"
                    |> Task.succeed
                    |> setInitResize RenderInfo.spec
            )
