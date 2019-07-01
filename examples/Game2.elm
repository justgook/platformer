module Game2 exposing (game, main)

import Json.Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.ShootEmUp as ShootEmUp


game : Launcher.Document flags ShootEmUp.World
game =
    ShootEmUp.game


main : Launcher Value ShootEmUp.World
main =
    --    Launcher.document { game | init = debugInit }
    Launcher.document { game | init = \_ -> ShootEmUp.load "./shootEmUp/demo.json" }



--    Launcher.document { game | init = init }
