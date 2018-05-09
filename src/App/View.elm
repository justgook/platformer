module App.View exposing (view)

import App.Message as Message exposing (Message)
import Game.Message as Game
import Game.Logic.Message as Logic
import App.Model exposing (Model, InputType(Keyboard))
import Game.View as Game
import VirtualDom exposing (Node, onWithOptions, Property)
import Json.Decode as Json
import WebGL
import Slime.Engine


view : Model -> Node Message
view { style, game, device, height } =
    WebGL.toHtmlWith
        [ WebGL.alpha False
        , WebGL.depth 1
        , WebGL.clearColor 0 0 0 1
        ]
        (style
            ++ (if device.inputType /= Keyboard then
                    [ onClick height ]
                else
                    [ onClick height ]
               )
        )
        (Game.view game)


onClick : Int -> Property Message
onClick height =
    Json.map2
        (\x y ->
            Message.Game (Game.Logic (Slime.Engine.Msg (Logic.Click { x = x, y = y, height = height })))
        )
        (Json.field "clientX" Json.int)
        (Json.field "clientY" Json.int)
        |> onWithOptions "click" { stopPropagation = True, preventDefault = True }
