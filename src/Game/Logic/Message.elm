module Game.Logic.Message exposing (Exception(..), Message(..))

import Game.Logic.World exposing (World)
import Keyboard.Extra


type Exception
    = Restart
    | CheckPoint World
    | Pause


type Message
    = Input Keyboard.Extra.Msg
    | Click { x : Int, y : Int, height : Int }
    | Exception Exception
