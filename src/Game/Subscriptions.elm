module Game.Subscriptions exposing (subscriptions)

import Game.Logic.Subscriptions as ECS
import Game.Message as Message
import Game.Model exposing (Model)


subscriptions : Model -> Sub Message.Message
subscriptions model =
    Sub.map Message.Logic (ECS.subscriptions model)
