module Logic.Template.OnScreenControl exposing (OnScreenControl, dir8, empty, example, pointerConfig, position, stick, stickWith, touchConfig)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Json.Decode as Decode exposing (Decoder)
import VirtualDom exposing (Handler(..), attribute, style)


type alias OnScreenControl a =
    { a
        | active : Bool
        , center : Vec2
        , cursor : Vec2
    }


empty : OnScreenControl {}
empty =
    { active = False
    , center = { x = 0, y = 0 }
    , cursor = { x = 0, y = 0 }
    }


position data =
    Vec2.normalize <| Vec2.sub data.center data.cursor


dir8 { center, cursor } =
    Vec2 (dir_ 5 center.x cursor.x) (dir_ 5 center.y cursor.y * -1)


dir_ dead a b =
    let
        current =
            a - b
    in
    if current * current < dead * dead then
        0

    else if a > b then
        -1

    else
        1


type alias EventConfig =
    { down : String
    , move : String
    , leave : String
    , up : String
    }


touchConfig : EventConfig
touchConfig =
    { down = "touchstart"
    , move = "touchmove"
    , leave = "touchcancel"
    , up = "touchend"
    }


pointerConfig : EventConfig
pointerConfig =
    { down = "pointerdown"
    , move = "pointermove"
    , leave = "pointerleave"
    , up = "pointerup"
    }


stickWith : EventConfig -> OnScreenControl a -> ((OnScreenControl a -> OnScreenControl a) -> msg) -> List (VirtualDom.Node msg) -> VirtualDom.Node msg
stickWith config info handler =
    let
        active_ =
            if info.active then
                (::) (attribute "class" "active") >> (::) (on config.move pointermove handler)

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
            , on config.down pointerdown handler
            , on config.leave pointerup handler
            , on config.up pointerup handler
            ]
        )


stick : OnScreenControl a -> ((OnScreenControl a -> OnScreenControl a) -> msg) -> VirtualDom.Node msg
stick info handler =
    stickWith touchConfig info handler (example info)


example : OnScreenControl a -> List (VirtualDom.Node msg)
example ({ center } as info) =
    let
        div =
            VirtualDom.node "div"

        px : Int -> String
        px a =
            String.fromInt a ++ "px"

        px2 : Float -> String
        px2 =
            round >> px

        backAttr x_ y_ =
            [ attribute "class" "back"
            , style "left" (px2 x_)
            , style "top" (px2 y_)
            ]

        frontAttr x_ y_ =
            [ attribute "class" "front"
            , style "left" (px2 x_)
            , style "top" (px2 y_)
            ]

        pos =
            limitDistance 40 info
    in
    [ div (backAttr center.x center.y) []
    , div (frontAttr pos.x pos.y) []
    ]


limitDistance maxDistance { center, cursor } =
    let
        maxDistanceSquared =
            maxDistance * maxDistance

        distance =
            Vec2.sub cursor center

        lengthSquared =
            Vec2.lengthSquared distance
    in
    if lengthSquared < maxDistanceSquared then
        cursor

    else
        distance
            |> Vec2.normalize
            |> Vec2.scale maxDistance
            |> Vec2.add center


on : String -> (a -> Decoder { message : msg, preventDefault : Bool, stopPropagation : Bool }) -> a -> VirtualDom.Attribute msg
on event decoder_ handler =
    VirtualDom.on event (Custom (decoder_ handler))


pointermove : ((OnScreenControl a -> OnScreenControl a) -> b) -> Decoder { message : b, preventDefault : Bool, stopPropagation : Bool }
pointermove handler =
    decodeMap2
        (\x y ->
            handler
                (\data ->
                    { data
                        | cursor = vec2 x y

                        --                            ,
                    }
                )
        )


pointerdown : ((OnScreenControl a -> OnScreenControl a) -> b) -> Decoder { message : b, preventDefault : Bool, stopPropagation : Bool }
pointerdown handler =
    decodeMap2
        (\x y ->
            handler
                (\data ->
                    { data
                        | center = vec2 x y
                        , cursor = vec2 x y
                        , active = True
                    }
                )
        )


pointerup : ((OnScreenControl a -> OnScreenControl a) -> b) -> Decoder { message : b, preventDefault : Bool, stopPropagation : Bool }
pointerup handler =
    Decode.succeed
        { message =
            handler
                (\data ->
                    { data
                        | active = False
                        , cursor = data.center
                    }
                )
        , stopPropagation = True
        , preventDefault = True
        }


decodeMap2 f =
    Decode.map2
        (\x y ->
            { message = f x y
            , stopPropagation = True
            , preventDefault = True
            }
        )
        (Decode.oneOf
            [ Decode.field "offsetX" Decode.float
            , Decode.at [ "touches", "0", "clientX" ] Decode.float
            ]
        )
        (Decode.oneOf
            [ Decode.field "offsetY" Decode.float
            , Decode.at [ "touches", "0", "clientY" ] Decode.float
            ]
        )
