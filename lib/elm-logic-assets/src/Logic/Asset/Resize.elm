module Logic.Asset.Resize exposing (Resize, apply, canvasStyle, empty, spec, sub, task)

import Browser.Dom as Browser exposing (Viewport)
import Browser.Events as Events
import Logic.Component.Singleton
import VirtualDom


type alias Resize a =
    { a
        | height : Int
        , width : Int
        , widthRatio : Float
        , devicePixelRatio : Float
    }


sub : Logic.Component.Singleton.Spec (Resize a) world -> world -> Sub world
sub spec_ world_ =
    Events.onResize (\w h -> apply_ spec_ w h world_)


spec : Logic.Component.Singleton.Spec (Resize a) { world | env : Resize a }
spec =
    { get = .env
    , set = \comps world -> { world | env = comps }
    }


empty : Resize {}
empty =
    { height = 0
    , width = 0
    , widthRatio = 0
    , devicePixelRatio = 1
    }


canvasStyle : Resize a -> List (VirtualDom.Attribute msg)
canvasStyle env =
    [ toFloat env.width * env.devicePixelRatio |> round |> String.fromInt |> VirtualDom.attribute "width"
    , toFloat env.height * env.devicePixelRatio |> round |> String.fromInt |> VirtualDom.attribute "height"
    , VirtualDom.style "display" "block"
    , VirtualDom.style "width" (String.fromInt env.width ++ "px")
    , VirtualDom.style "height" (String.fromInt env.height ++ "px")
    ]


apply : Logic.Component.Singleton.Spec (Resize a) world -> Viewport -> world -> world
apply spec_ { scene } world =
    let
        w =
            round scene.width

        h =
            round scene.height
    in
    apply_ spec_ w h world


apply_ : Logic.Component.Singleton.Spec (Resize a) world -> Int -> Int -> world -> world
apply_ { set, get } w h world =
    let
        env =
            get world
    in
    set
        { env
            | width = w
            , height = h
            , widthRatio = toFloat w / toFloat h
        }
        world


task =
    Browser.getViewport
