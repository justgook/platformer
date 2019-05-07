module Nipple exposing
    ( dir
    , container, stylesheet
    )

{-|

@docs dir

-}

import VirtualDom exposing (Node, style)


{-|

           \  UP /
            \   /
       LEFT       RIGHT
            /   \
           /DOWN \

-}
dir : List (Node msg)
dir =
    [ VirtualDom.node "figure" [ class "back" ] []
    , VirtualDom.node "figure" [ class "front" ] []
    ]


stylesheet =
    VirtualDom.node "style" [] [ text """
.nipple {position:absolute}
.nipple .front {
    border-radius:50%;
    width: 50px;
    height: 50px;
    background:blue;
    position:absolute;
}
.nipple .back {
    border-radius:50%;
    width: 300px;
    height:300px;
    background:red;
    position:absolute;
}
""" ]


container css nipple =
    let
        mainCss =
            class "nipple"
                :: style "top" "0"
                :: style "left" "0"
                :: css
    in
    VirtualDom.node "section"
        mainCss
        nipple


text =
    VirtualDom.text


class =
    VirtualDom.attribute "class"



--<div class="nipple">
--    <div class="front"></div>
--    <div class="back"></div>
--</div>\
