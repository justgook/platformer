module Physic.Narrow.Body exposing
    ( Body
    , boundary
    , debuInfo
    , ellipse
    , getIndex
    , getPosition
    , getVelocity
    , isStatic
    , rect
    , rotate
    , setVelocity
    , toStatic
    , translate
    , union
    , withIndex
    )

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Broad exposing (Boundary)
import Physic.Narrow.Common as Generic exposing (Generic, Options, defaultOptions)
import Physic.Util exposing (normal, rotateClockwise)



--https://thebookofshaders.com/12/


type Body i
    = Circle__ (Generic i)
    | Ellipse__ (Generic i) { r2 : Float }
    | Rectangle__ (Generic i) { h : Float }



--http://brm.io/matter-js/docs/classes/Bodies.html


withIndex : i -> Body i -> Body i
withIndex i body =
    updateGeneric__ (\o -> { o | index = Just i }) body


getIndex : Body i -> Maybe i
getIndex body =
    getFromGeneric__ .index body


toStatic : Body i -> Body i
toStatic body =
    updateGeneric__ (\o -> { o | invMass = 0 }) body


isStatic : Body i -> Bool
isStatic body =
    getFromGeneric__ (.invMass >> (==) 0) body


rect : Float -> Float -> Float -> Float -> Body comparable
rect x y w h =
    rectWith x y w h defaultOptions


rectWith : Float -> Float -> Float -> Float -> Options comparable -> Body comparable
rectWith x y w h options =
    Rectangle__
        (Generic.empty (vec2 x y) (vec2 (w / 2) 0) options)
        { h = h / 2 }


ellipseWith : Float -> Float -> Float -> Float -> Options comparable -> Body comparable
ellipseWith x y r1 r2 options =
    if r1 == r2 then
        Circle__
            (Generic.empty (vec2 x y) (vec2 r1 0) options)
        --            { invMass = 1 / options.mass
        --            , index = options.index
        --            , p = vec2 x y
        --            , r = vec2 r1 0
        --            , velocity = vec2 0 0
        --            }

    else
        Ellipse__
            --            { invMass = 1 / options.mass
            --            , index = options.index
            --            , p = vec2 x y
            --            , r = vec2 r1 0
            --            , velocity = vec2 0 0
            --            }
            (Generic.empty (vec2 x y) (vec2 r1 0) options)
            { r2 = r2 }


ellipse : Float -> Float -> Float -> Float -> Body comparable
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
            , invMass = o1.invMass + o2.invMass
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
            , invMass = o1.invMass + o2.invMass
        }
        { h = h }


union : Body i -> Body i -> Maybe (Body i)
union body1 body2 =
    case ( body1, body2 ) of
        ( Rectangle__ o1 o11, Rectangle__ o2 o22 ) ->
            --Can produce wrong results when shapes have different sizes
            -- TODO add support for 180° rotated shapes
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


getVelocity : Body i -> Vec2
getVelocity body =
    getFromGeneric__ .velocity body


getPosition : Body i -> Vec2
getPosition body =
    getFromGeneric__ .p body


setPosition p body =
    updateGeneric__ (\o -> { o | p = p }) body


rotate angle body =
    --    add trnslation to correct point to make rotation around correct pivot
    updateGeneric__
        (\o -> { o | r = rotateClockwise angle o.r })
        body


boundary : Body a -> Boundary
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


setVelocity : Vec2 -> Body i -> Body i
setVelocity v body =
    updateGeneric__ (\o -> { o | velocity = v }) body


translate : Vec2 -> Body i -> Body i
translate p body =
    updateGeneric__ (\o -> { o | p = Vec2.add o.p p }) body


debuInfo :
    { b
        | circle : Vec2 -> Float -> a
        , ellipse : Vec2 -> Float -> Float -> a
        , rectangle : Vec2 -> Float -> Float -> a
        , radiusRectangle : Vec2 -> Vec2 -> Float -> a
    }
    -> Body i
    -> a
debuInfo draw body =
    -- TODO add rotation
    --    radiusRectangle
    case body of
        Circle__ o ->
            draw.circle o.p (Vec2.length o.r)

        Ellipse__ o { r2 } ->
            draw.ellipse o.p (Vec2.length o.r) r2

        Rectangle__ o { h } ->
            draw.radiusRectangle o.p o.r h



--            draw.rectangle o.p (Vec2.length o.r * 2) (h * 2)


updateGeneric__ : (Generic i -> Generic i) -> Body i -> Body i
updateGeneric__ f body =
    case body of
        Circle__ o ->
            Circle__ (f o)

        Ellipse__ o a ->
            Ellipse__ (f o) a

        Rectangle__ o a ->
            Rectangle__ (f o) a


getFromGeneric__ : (Generic i -> a) -> Body i -> a
getFromGeneric__ f body =
    case body of
        Circle__ o ->
            f o

        Ellipse__ o _ ->
            f o

        Rectangle__ o _ ->
            f o
