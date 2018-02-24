module Game.Logic.Message exposing (Message(..))

import Keyboard.Extra


type Message
    = Input Keyboard.Extra.Msg
