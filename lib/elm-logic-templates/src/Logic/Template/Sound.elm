module Logic.Template.Sound exposing (id, play, sprite, stop)

import VirtualDom


play src key attrs =
    VirtualDom.node
        "howler-sound"
        (VirtualDom.property "src" src
            :: VirtualDom.attribute "data-key" key
            :: attrs
        )
        []


type Attributes
    = Volume Float
    | Loop Bool


id value =
    VirtualDom.attribute "sound-id" value


sprite value =
    VirtualDom.property "sprite" value


volume value =
    VirtualDom.attribute "volume" value


stop value =
    VirtualDom.attribute "stop" value
