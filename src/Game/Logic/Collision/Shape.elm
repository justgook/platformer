module Game.Logic.Collision.Shape
    exposing
        ( AabbData
        , Shape(..)
        , aabb
        , aabbData
        , boolean
        , position
        , response
        , setPosition
        , updatePosition
        )

import Math.Vector2 as Vec2 exposing (Vec2, vec2)


type Shape
    = AABB AabbData
    | Circle { p : Vec2, xw : Vec2, yw : Vec2 }
    | Point { p : Vec2 }


type AabbData
    = AabbData
        { p : Vec2
        , xw : Vec2
        , yw : Vec2

        -- Precalculated data
        , sum_ : Vec2
        , projX_ : Vec2
        , projY_ : Vec2
        }


aabbData : Shape -> { p : Vec2, xw : Vec2, yw : Vec2 }
aabbData shape =
    case shape of
        AABB (AabbData { p, xw, yw }) ->
            { p = p, xw = xw, yw = yw }

        Circle { p, xw, yw } ->
            { p = p, xw = xw, yw = yw }

        Point { p } ->
            { p = p, xw = vec2 0 0, yw = vec2 0 0 }


position : Shape -> Vec2
position shape =
    case shape of
        AABB (AabbData { p }) ->
            p

        Point { p } ->
            p

        Circle { p } ->
            p


setPosition : Vec2 -> Shape -> Shape
setPosition p shape =
    case shape of
        AABB (AabbData data) ->
            aabb { data | p = p }

        Point data ->
            Point { p = p }

        Circle data ->
            Circle { data | p = p }


updatePosition : Vec2 -> Shape -> Shape
updatePosition p shape =
    case shape of
        AABB (AabbData data) ->
            aabb { data | p = Vec2.add data.p p }

        Point data ->
            Point { p = Vec2.add data.p p }

        Circle data ->
            Circle { data | p = Vec2.add data.p p }


aabb : { a | p : Vec2, xw : Vec2, yw : Vec2 } -> Shape
aabb { p, xw, yw } =
    let
        sum_ =
            Vec2.add xw yw
    in
    AabbData
        { p = p
        , xw = xw
        , yw = yw
        , sum_ = sum_
        , projX_ = projection sum_ (vec2 1 0)
        , projY_ = projection sum_ (vec2 0 1)
        }
        |> AABB


boolean : Shape -> Shape -> Bool
boolean a b =
    response a b /= Nothing


response : Shape -> Shape -> Maybe Vec2
response a b =
    --Find why i need to swap
    case ( b, a ) of
        ( AABB (AabbData data1), AABB (AabbData data2) ) ->
            let
                difference =
                    Vec2.sub data1.p data2.p

                projX =
                    -- projecton of that to X axis
                    projection difference (vec2 1 0)

                projY =
                    -- projecton of that to Y axis
                    projection difference (vec2 0 1)

                testX =
                    Vec2.add data1.projX_ data2.projX_
                        |> applyIf Vec2.negate (Vec2.getX difference < 0)
                        |> Vec2.sub projX
            in
            if Vec2.getX testX /= 0 && signCheck Vec2.getX testX projX then
                let
                    testY =
                        Vec2.add data1.projY_ data2.projY_
                            |> applyIf Vec2.negate (Vec2.getY difference < 0)
                            |> Vec2.sub projY
                in
                if Vec2.getY testY /= 0 && signCheck Vec2.getY testY projY then
                    Just (smallerByLength testY testX)
                else
                    Nothing
            else
                Nothing

        _ ->
            Nothing


applyIf : (a -> a) -> Bool -> a -> a
applyIf func expr a =
    if expr then
        func a
    else
        a


smallerByLength : Vec2 -> Vec2 -> Vec2
smallerByLength a b =
    if Vec2.length a > Vec2.length b then
        b
    else
        a


signCheck : (a -> comparable) -> a -> a -> Bool
signCheck getter a_ b_ =
    let
        a =
            getter a_

        b =
            getter b_
    in
    (a >= 0) /= (b >= 0)


{-| projecting vector a onto vector b
-}
projection : Vec2 -> Vec2 -> Vec2
projection a b =
    let
        bx =
            Vec2.getX b

        by =
            Vec2.getY b

        ax =
            Vec2.getX a

        ay =
            Vec2.getY a

        dp =
            ax * bx + ay * by

        x =
            (dp / (bx * bx + by * by)) * bx

        y =
            (dp / (bx * bx + by * by)) * by
    in
    vec2 x y
