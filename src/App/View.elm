module App.View exposing (view)

import App.Message exposing (Message)
import App.Model exposing (Model)
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import WebGL


view : Model -> Html Message
view { style } =
    WebGL.toHtml
        (style2 :: style)
        []


style2 : Html.Attribute Message
style2 =
    style
        [ ( "background-color", "rgb(221, 221, 221)" )
        , ( "background-image", "linear-gradient(45deg, rgb(245, 245, 245) 25%, transparent 25%, transparent 75%, rgb(245, 245, 245) 75%, rgb(245, 245, 245)), linear-gradient(45deg, rgb(245, 245, 245) 25%, transparent 25%, transparent 75%, rgb(245, 245, 245) 75%, rgb(245, 245, 245))" )
        , ( "background-position", "0px 0px, 9px 9px" )
        , ( "background-size", "18px 18px" )
        ]
