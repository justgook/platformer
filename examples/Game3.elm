module Game3 exposing (game, main)

import Json.Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.TopDown as TopDown exposing (World, game)



--import Task


game : Launcher.Document flags TopDown.World
game =
    TopDown.game


main : Launcher Value TopDown.World
main =
    Launcher.document { game | init = \_ -> TopDown.run "game.bin" }
