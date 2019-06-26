module Presentation exposing (main)

import Base64
import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.Presentation as Presentation
import Task


game : Launcher.Document flags Presentation.World
game =
    Presentation.game


main : Launcher Value Presentation.World
main =
    --    Launcher.document { game | init = init }
    --    Launcher.document { game | init = debugInit }
    Launcher.document { game | init = \_ -> Presentation.load "./elm-europe/slides2.json" }



--    Launcher.document { game | init = init }
