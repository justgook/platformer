module App.View exposing (view)

import App.Message exposing (Message)
import App.Model exposing (Model)
import Game.View as Game
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
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
        (style2 :: style)
        result


style2 : Html.Attribute Message
style2 =
    style
        [ ( "background-color", "rgb(221, 221, 221)" )
        , ( "background-image", "linear-gradient(45deg, rgb(245, 245, 245) 25%, transparent 25%, transparent 75%, rgb(245, 245, 245) 75%, rgb(245, 245, 245)), linear-gradient(45deg, rgb(245, 245, 245) 25%, transparent 25%, transparent 75%, rgb(245, 245, 245) 75%, rgb(245, 245, 245))" )
        , ( "background-position", "0px 0px, 9px 9px" )
        , ( "background-size", "18px 18px" )
        , ( "image-rendering", "optimizeSpeed" )
        , ( "image-rendering", "-moz-crisp-edges" )
        , ( "image-rendering", "-webkit-optimize-contrast" )
        , ( "image-rendering", "-o-crisp-edges" )
        , ( "image-rendering", "pixelated" )
        , ( "-ms-interpolation-mode", "nearest-neighbor" )
        ]
