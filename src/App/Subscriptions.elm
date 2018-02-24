module App.Subscriptions exposing (subscriptions)

import App.Message as Message exposing (Message)
import App.Model exposing (Model)
import Game.Subscriptions as Game
import Window


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Window.resizes Message.Window
        , Sub.map Message.Game (Game.subscriptions model.game)
        ]
