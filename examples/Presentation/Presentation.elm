module Presentation exposing (main)

import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Error(..), Launcher)
import Logic.Template.Game.Presentation as Presentation


game : Launcher.Document flags Presentation.World
game =
    Presentation.game


main : Launcher Value Presentation.World
main =
    Launcher.document { game | init = \_ -> Presentation.run "game.bin" }
