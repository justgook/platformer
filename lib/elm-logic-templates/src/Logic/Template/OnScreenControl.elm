module Logic.Template.OnScreenControl exposing (OnScreenControl, dir8, empty, example, position, stick, stickWith)

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


stickWith : OnScreenControl a -> ((OnScreenControl a -> OnScreenControl a) -> msg) -> List (VirtualDom.Node msg) -> VirtualDom.Node msg
stickWith info handler =
    let
        active_ =
            if info.active then
                (::) (attribute "class" "active") >> (::) (on "pointermove" onpointermove handler)

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
            , on "pointerdown" pointerdown handler
            , on "pointerleave" pointerup handler
            , on "pointerup" pointerup handler
            ]
        )


stick : OnScreenControl a -> ((OnScreenControl a -> OnScreenControl a) -> msg) -> VirtualDom.Node msg
stick info handler =
    stickWith info handler (example info)


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


onpointermove : ((OnScreenControl a -> OnScreenControl a) -> b) -> Decoder { message : b, preventDefault : Bool, stopPropagation : Bool }
onpointermove handler =
    Decode.map2
        (\x y ->
            { message =
                handler
                    (\data ->
                        { data
                            | cursor = vec2 x y

                            --                            ,
                        }
                    )
            , stopPropagation = True
            , preventDefault = True
            }
        )
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


pointerdown : ((OnScreenControl a -> OnScreenControl a) -> b) -> Decoder { message : b, preventDefault : Bool, stopPropagation : Bool }
pointerdown handler =
    Decode.map2
        (\x y ->
            { message =
                handler
                    (\data ->
                        { data
                            | center = vec2 x y
                            , cursor = vec2 x y
                            , active = True
                        }
                    )
            , stopPropagation = True
            , preventDefault = True
            }
        )
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


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
