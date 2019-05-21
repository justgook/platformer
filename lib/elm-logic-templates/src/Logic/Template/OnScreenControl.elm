module Logic.Template.OnScreenControl exposing (EventConfig, stickWith)

import Json.Decode as Decode exposing (Decoder)
import VirtualDom exposing (Handler(..), attribute, style)


type alias EventConfig msg =
    { down : ( String, Float -> Float -> msg )
    , move : ( String, Float -> Float -> msg )
    , leave : ( String, msg )
    , up : ( String, msg )
    }


stickWith : EventConfig msg -> Bool -> List (VirtualDom.Node msg) -> VirtualDom.Node msg
stickWith config active =
    let
        active_ =
            if active then
                (::) (attribute "class" "active") >> (::) (on2 config.move)

            else
                identity
    in
    VirtualDom.node "div"
        (active_
            [ style "position" "absolute"
            , style "top" "0"
            , style "right" "0"
            , style "bottom" "0"
            , style "left" "0"
            , on2 config.down
            , on1 config.up
            , on1 config.leave
            ]
        )


on2 : ( String, Float -> Float -> msg ) -> VirtualDom.Attribute msg
on2 ( event, f ) =
    VirtualDom.on event
        (Custom
            (Decode.map2
                (\x y ->
                    { message = f x y
                    , stopPropagation = True
                    , preventDefault = True
                    }
                )
                --(Decode.oneOf
                --            [ Decode.field "offsetX" Decode.float
                --            , Decode.at [ "touches", "0", "clientX" ] Decode.float
                --            ]
                --        )
                (Decode.at [ "targetTouches", "0", "clientX" ] Decode.float)
                (Decode.at [ "targetTouches", "0", "clientY" ] Decode.float)
            )
        )


on1 : ( String, msg ) -> VirtualDom.Attribute msg
on1 ( event, msg ) =
    VirtualDom.on event (Custom (Decode.succeed { message = msg, stopPropagation = True, preventDefault = True }))
