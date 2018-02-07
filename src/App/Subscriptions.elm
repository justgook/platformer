module App.Subscriptions exposing (subscriptions)

import AnimationFrame
import App.Message as Message exposing (Message)
import App.Model exposing (Model)
import Window


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs Message.Animate
        , Window.resizes Message.Window
        ]
