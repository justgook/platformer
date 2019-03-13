module Physic.Body exposing (Body, boundary, debuInfo, ellipse, getPosition, isStatic, rect, setVelocity, toStatic, translate, union, velocity)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Physic.Util exposing (normal)


type Body
    = Circle__ Generic
    | Ellipse__ Generic { r2 : Float }
    | Rectangle__ Generic { h : Float }



--http://brm.io/matter-js/docs/classes/Bodies.html


type alias Options =
    { mass : Float
    , sleep : Bool
    }


defaultOptions : Options
defaultOptions =
    { mass = 1
    , sleep = False
    }


type alias Generic =
    { p : Vec2
    , r : Vec2
    , velocity : Vec2
    , mass : Float
    }


toStatic : Body -> Body
toStatic body =
    updateGeneric__ (\o -> { o | mass = 0 }) body


isStatic : Body -> Bool
isStatic body =
    getFromGeneric__ (.mass >> (==) 0) body


rect : Float -> Float -> Float -> Float -> Body
rect x y w h =
    rectWith x y w h defaultOptions


rectWith : Float -> Float -> Float -> Float -> Options -> Body
rectWith x y w h options =
    Rectangle__
        { mass = options.mass
        , p = vec2 x y
        , r = vec2 (w / 2) 0
        , velocity = vec2 0 0
        }
        { h = h / 2 }


ellipseWith : Float -> Float -> Float -> Float -> Options -> Body
ellipseWith x y r1 r2 options =
    if r1 == r2 then
        Circle__
            { mass = options.mass
            , p = vec2 x y
            , r = vec2 r1 0
            , velocity = vec2 0 0
            }

    else
        Ellipse__
            { mass = options.mass
            , p = vec2 x y
            , r = vec2 r1 0
            , velocity = vec2 0 0
            }
            { r2 = r2 }


ellipse : Float -> Float -> Float -> Float -> Body
ellipse x y r1 r2 =
    ellipseWith x y r1 r2 defaultOptions


horizontalUnion o1 o2 h =
    let
        newR_ =
            Vec2.add o1.r o2.r

        newP__ =
            Vec2.sub o1.p o1.r
                |> Vec2.add newR_
    in
    Rectangle__
        { o1
            | r = newR_
            , p = newP__
            , mass = o1.mass + o2.mass
        }
        { h = h }


verticalUnion o1 o2 h o1r2 normal1 =
    let
        newP__ =
            Vec2.add
                (Vec2.add o1.p o1r2)
                (Vec2.scale h normal1)
    in
    Rectangle__
        { o1
            | r = o1.r
            , p = newP__
            , mass = o1.mass + o2.mass
        }
        { h = h }


union : Body -> Body -> Maybe Body
union body1 body2 =
    case ( body1, body2 ) of
        ( Rectangle__ o1 o11, Rectangle__ o2 o22 ) ->
            let
                normal1 =
                    normal o1.r

                normal2 =
                    normal o2.r

                o1r2 =
                    { a = Vec2.scale o11.h normal1.a
                    , b = Vec2.scale o11.h normal1.b
                    }

                o2r2 =
                    { a = Vec2.scale o22.h normal2.a
                    , b = Vec2.scale o22.h normal2.b
                    }
            in
            if Vec2.add o1.p o1r2.b == Vec2.add o2.p o2r2.a then
                verticalUnion o2 o1 (o11.h + o22.h) o2r2.b normal2.a
                    |> Just

            else if Vec2.add o1.p o1r2.a == Vec2.add o2.p o2r2.b then
                verticalUnion o1 o2 (o11.h + o22.h) o1r2.b normal1.a
                    |> Just

            else if Vec2.add o1.p o1.r == Vec2.sub o2.p o2.r then
                horizontalUnion o1 o2 o11.h
                    |> Just

            else if Vec2.sub o1.p o1.r == Vec2.add o2.p o2.r then
                horizontalUnion o2 o1 o11.h
                    |> Just

            else
                Nothing

        _ ->
            Nothing


velocity body =
    updateGeneric__ (\o -> { o | p = Vec2.add o.p o.velocity }) body


getPosition body =
    getFromGeneric__ .p body


setPosition p body =
    updateGeneric__ (\o -> { o | p = p }) body


boundary body =
    case body of
        Circle__ o ->
            let
                { x, y } =
                    Vec2.toRecord o.p

                length =
                    Vec2.length o.r
            in
            { xmin = x - length
            , xmax = x + length
            , ymin = y - length
            , ymax = y + length
            }

        Ellipse__ o { r2 } ->
            let
                { x, y } =
                    Vec2.toRecord o.p

                length =
                    Vec2.length o.r
            in
            { xmin = x - length
            , xmax = x + length
            , ymin = y - r2
            , ymax = y + r2
            }

        Rectangle__ o { h } ->
            let
                { x, y } =
                    Vec2.toRecord o.p

                w =
                    Vec2.length o.r
            in
            { xmin = x - w
            , xmax = x + w
            , ymin = y - h
            , ymax = y + h
            }


setVelocity v body =
    updateGeneric__ (\o -> { o | velocity = v }) body


translate p body =
    updateGeneric__ (\o -> { o | p = Vec2.add o.p p }) body


debuInfo : { b | circle : Vec2 -> Float -> a, ellipse : Vec2 -> Float -> Float -> a, rectangle : Vec2 -> Float -> Float -> a } -> Body -> a
debuInfo draw body =
    -- TODO add rotation
    case body of
        Circle__ o ->
            draw.circle o.p (Vec2.length o.r)

        Ellipse__ o { r2 } ->
            draw.ellipse o.p (Vec2.length o.r) r2

        Rectangle__ o { h } ->
            draw.rectangle o.p (Vec2.length o.r * 2) (h * 2)


updateGeneric__ : (Generic -> Generic) -> Body -> Body
updateGeneric__ f body =
    case body of
        Circle__ o ->
            Circle__ (f o)

        Ellipse__ o a ->
            Ellipse__ (f o) a

        Rectangle__ o a ->
            Rectangle__ (f o) a


getFromGeneric__ : (Generic -> a) -> Body -> a
getFromGeneric__ f body =
    case body of
        Circle__ o ->
            f o

        Ellipse__ o _ ->
            f o

        Rectangle__ o _ ->
            f o
