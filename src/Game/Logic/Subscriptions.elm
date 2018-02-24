module Game.Logic.Subscriptions exposing (subscriptions)

import Game.Logic.Message exposing (Message(Input))
import Keyboard.Extra
import Slime.Engine


subscriptions_ : a -> Sub Message
subscriptions_ model =
    Sub.map Input Keyboard.Extra.subscriptions


subscriptions : a -> Sub (Slime.Engine.Message Message)
subscriptions =
    subscriptions_ >> Slime.Engine.engineSubs
