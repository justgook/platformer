module Logic.Template.Game.Presentation.Slide exposing (Slide, slide, view)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Logic.Template.Camera.Trigger exposing (Trigger)
import Math.Vector2
import VirtualDom exposing (Node, text)


type alias Slide_ a msg =
    Vec2 -> Vec2 -> List (Node msg) -> Slide a msg


type alias Slide a msg =
    Trigger a -> Float -> Node msg


div =
    VirtualDom.node "div"


screen style =
    div
        (VirtualDom.style "position" "absolute"
            :: VirtualDom.style "left" "0"
            :: VirtualDom.style "bottom" "0"
            :: VirtualDom.style "overflow" "hidden"
            :: style
        )


slide : Slide_ a msg
slide pos size content camera px =
    let
        pos_ =
            camera.viewportOffset
                |> Vec2.sub pos
                |> Vec2.scale px

        size_ =
            Vec2.scale px size
    in
    div
        (VirtualDom.style "position" "absolute"
            :: VirtualDom.attribute "class" "slide"
            :: VirtualDom.style "box-sizing" "border-box"
            --            :: VirtualDom.style "background" "red"
            :: VirtualDom.style "left" (String.fromFloat pos_.x ++ "px")
            :: VirtualDom.style "bottom" (String.fromFloat pos_.y ++ "px")
            --            :: VirtualDom.style "background" "white"
            :: VirtualDom.style "width" (String.fromFloat size_.x ++ "px")
            :: VirtualDom.style "height" (String.fromFloat size_.y ++ "px")
            :: VirtualDom.style "overflow" "hidden"
            :: []
        )
        content


view style slides =
    screen style slides
