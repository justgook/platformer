module App.Message exposing (Message(..))

import Game.Message as Game
import Time
import Window exposing (Size)


type Message
    = Window Size
    | Game Game.Message
