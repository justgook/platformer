module Game.ECS.Message exposing (Message(..))

import Keyboard.Extra


type Message
    = Input Keyboard.Extra.Msg
