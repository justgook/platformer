module App.Subscriptions exposing (subscriptions)

import AnimationFrame
import App.Message as Message exposing (Message)
import App.Model exposing (Model)
import Game.Message as Game
import Window


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs (Message.Game << Game.Animate)
        , Window.resizes Message.Window
        ]
