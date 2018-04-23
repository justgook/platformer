module Game.Logic.Message exposing (Exception(..), Message(..))

import Game.Logic.World as World exposing (World)
import Keyboard.Extra


type Exception
    = Restart
    | CheckPoint World
    | Pause


type Message
    = Input Keyboard.Extra.Msg
    | Exception Exception
