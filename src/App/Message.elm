module App.Message exposing (Message(..))

import Time exposing (Time)
import Window exposing (Size)


type Message
    = Window Size
    | Animate Time
