module Game.ECS.Subscriptions exposing (subscriptions)

import Game.ECS.Message exposing (Message(Input))
import Keyboard.Extra


subscriptions model =
    Sub.map Input Keyboard.Extra.subscriptions
