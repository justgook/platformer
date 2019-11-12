module Logic.Template.Component.OnScreenControl exposing (Stick, TwoButtonStick, dir8, empty, emptyTwoButtonStick, onscreenSpecExtend, spec, stick, twoButtonStick)

import AltMath.Vector2 as AVec2
import Logic.Component
import Logic.Component.Singleton as Singleton exposing (Spec)
import Logic.Entity as Entity exposing (EntityID)
import Logic.System as System
import Logic.Template.OnScreenControl exposing (EventConfig, stickWith)
import Set
import VirtualDom exposing (Handler(..), attribute, style)


dir8 center cursor =
    { x = dir_ 5 center.x cursor.x, y = dir_ 5 center.y cursor.y * -1 }


dir_ dead a b =
    let
        current =
            a - b
    in
    if current * current < dead * dead then
        0

    else
        clamp -40 40 current / -40


type alias XY =
    { x : Float, y : Float }


type alias Stick a =
    { a
        | active : Bool
        , center : XY
        , cursor : XY
    }


type alias Button a =
    { a | active : Bool, center : XY }


type alias TwoButtonStick a =
    Stick
        { button1 : Button a
        , button2 : Button a
        }


empty : Stick {}
empty =
    { active = False
    , center = { x = 0, y = 0 }
    , cursor = { x = 0, y = 0 }
    }


emptyTwoButtonStick : TwoButtonStick {}
emptyTwoButtonStick =
    { active = False
    , center = { x = 0, y = 0 }
    , cursor = { x = 0, y = 0 }
    , button1 =
        { active = False
        , center = { x = 0, y = 0 }
        }
    , button2 =
        { active = False
        , center = { x = 0, y = 0 }
        }
    }


twoButtonStick : Spec (TwoButtonStick a) world -> world -> VirtualDom.Node (world -> world)
twoButtonStick spec_ world =
    let
        info =
            spec_.get world
    in
    div
        [ style "position" "absolute"
        , style "top" "0"
        , style "right" "0"
        , style "bottom" "0"
        , style "left" "0"
        ]
        [ buttonHtml "button1" info.button1
        , buttonHtml "button2" info.button2
        , stickHtml info
        , leftHalf_ [ stickWith (touchConfig spec_) info.active [] ]
        , rightQuarter1_ [ stickWith (touchButtonConfig (button1Spec spec_)) info.button1.active [] ]
        , rightQuarter2_ [ stickWith (touchButtonConfig (button2Spec spec_)) info.button2.active [] ]
        ]


button2Spec spec_ =
    { get = spec_.get >> .button2
    , set =
        \c w ->
            let
                comp =
                    spec_.get w
            in
            spec_.set { comp | button2 = c } w
    }


button1Spec spec_ =
    { get = spec_.get >> .button1
    , set =
        \c w ->
            let
                comp =
                    spec_.get w
            in
            spec_.set { comp | button1 = c } w
    }


spec : Spec (Stick a) { world | onScreen : Stick a }
spec =
    { get = .onScreen
    , set = \comps world -> { world | onScreen = comps }
    }


onscreenSpecExtend :
    String
    -> String
    -> Spec (TwoButtonStick a) world
    -> Logic.Component.Spec { b | action : Set.Set String, x : Float, y : Float } world
    -> EntityID
    -> Spec (TwoButtonStick a) world
onscreenSpecExtend action1 action2 onScreenSpec inputSpec entityID =
    { get = onScreenSpec.get
    , set =
        \comp w ->
            let
                button1 =
                    if comp.button1.active then
                        Set.insert action1

                    else
                        Set.remove action1

                button2 =
                    if comp.button2.active then
                        Set.insert action2

                    else
                        Set.remove action2

                setXY { x, y } a =
                    { a | x = x, y = y }

                componentUpdaterInternal =
                    setXY (dir8 comp.center comp.cursor)
            in
            onScreenSpec.set comp w
                |> Singleton.update inputSpec
                    (System.map (\key -> componentUpdaterInternal { key | action = key.action |> button1 |> button2 }) entityID)
    }


touchConfig : Spec (Stick a) world -> EventConfig (world -> world)
touchConfig spec_ =
    { down = ( "touchstart", \x y -> Singleton.update spec_ (\data -> { data | center = XY x y, cursor = XY x y, active = True }) )
    , move = ( "touchmove", \x y -> Singleton.update spec_ (\data -> { data | cursor = XY x y }) )
    , leave = ( "touchcancel", Singleton.update spec_ (\data -> { data | active = False, cursor = data.center }) )
    , up = ( "touchend", Singleton.update spec_ (\data -> { data | active = False, cursor = data.center }) )
    }


touchButtonConfig : Spec (Button a) world -> EventConfig (world -> world)
touchButtonConfig spec_ =
    let
        active x y data =
            { data | active = True, center = XY x y }

        inActive data =
            { data | active = False }
    in
    { down = ( "touchstart", \x y -> Singleton.update spec_ (active x y) )
    , move = ( "touchmove", \_ _ -> identity )
    , leave = ( "touchcancel", Singleton.update spec_ inActive )
    , up = ( "touchend", Singleton.update spec_ inActive )
    }


rightQuarter1_ =
    div
        [ style "position" "absolute"
        , style "top" "0"
        , style "right" "25%"
        , style "bottom" "0"
        , style "left" "50%"
        ]


rightQuarter2_ =
    div
        [ style "position" "absolute"
        , style "top" "0"
        , style "right" "0"
        , style "bottom" "0"
        , style "left" "75%"
        ]


leftHalf_ =
    div
        [ style "position" "absolute"
        , style "top" "0"
        , style "right" "50%"
        , style "bottom" "0"
        , style "left" "0"
        ]


activate active =
    if active then
        [ attribute "class" "active" ]

    else
        []


buttonHtml : String -> Button a -> VirtualDom.Node msg
buttonHtml customClass button =
    let
        px : Int -> String
        px a =
            String.fromInt a ++ "px"

        px2 : Float -> String
        px2 =
            round >> px
    in
    div
        (activate button.active
            ++ [ attribute "class" "button"
               , attribute "class" customClass
               , style "left" (px2 button.center.x)
               , style "top" (px2 button.center.y)
               ]
        )
        []


stick : Spec (Stick a) world -> world -> VirtualDom.Node (world -> world)
stick spec_ world =
    let
        info =
            spec_.get world
    in
    div []
        [ stickHtml info
        , stickWith (touchConfig spec_) info.active []
        ]


stickHtml : Stick a -> VirtualDom.Node msg
stickHtml ({ center, active } as info) =
    let
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
            limitDistance_ 40 info
    in
    div (activate active)
        [ div (backAttr center.x center.y) []
        , div (frontAttr pos.x pos.y) []
        ]


limitDistance_ : Float -> Stick a -> { x : Float, y : Float }
limitDistance_ maxDistance data =
    let
        center =
            AVec2.fromRecord data.center

        cursor =
            AVec2.fromRecord data.cursor

        maxDistanceSquared =
            maxDistance * maxDistance

        distance =
            AVec2.sub cursor center

        lengthSquared =
            AVec2.lengthSquared distance
    in
    if lengthSquared < maxDistanceSquared then
        data.cursor

    else
        distance
            |> AVec2.normalize
            |> AVec2.scale maxDistance
            |> AVec2.add center
            |> AVec2.toRecord


div =
    VirtualDom.node "div"
