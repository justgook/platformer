module App.View exposing (view)

import App.Message exposing (Message)
import App.Model exposing (Model)
import Game.View as Game
import Html exposing (Html)
import WebGL exposing (Mesh, Shader, Texture)


view : Model -> Html Message
view { style, game } =
    let
        result =
            Game.view game
    in
        WebGL.toHtmlWith
            [ WebGL.alpha False
            , WebGL.depth 1
            , WebGL.clearColor 0 0 0 1
            ]
            style
            result
