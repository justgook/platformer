module Game.Message exposing (Message(..))

import Game.Level exposing (Level)
import Http


type Message
    = LoadLevel (Result Http.Error Level)
