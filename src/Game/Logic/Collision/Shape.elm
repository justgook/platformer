module Game.Logic.Collision.Shape
    exposing
        ( AabbData
        , Shape(..)
        , WithShape
        , aabbData
          -- , boolean
        , createAABB
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


type alias WithShape a =
    { a
        | shape : Shape
    }


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


aabbData : WithShape a -> { p : Vec2, xw : Vec2, yw : Vec2 }
aabbData { shape } =
    case shape of
        AABB (AabbData { p, xw, yw }) ->
            { p = p, xw = xw, yw = yw }

        Circle { p, xw, yw } ->
            { p = p, xw = xw, yw = yw }

        Point { p } ->
            { p = p, xw = vec2 0 0, yw = vec2 0 0 }


position : WithShape a -> Vec2
position { shape } =
    case shape of
        AABB (AabbData { p }) ->
            p

        Point { p } ->
            p

        Circle { p } ->
            p


setPosition : Vec2 -> WithShape a -> WithShape a
setPosition p ({ shape } as shaped) =
    case shape of
        AABB (AabbData data) ->
            { shaped | shape = createAABB { data | p = p } }

        Point _ ->
            { shaped | shape = Point { p = p } }

        Circle data ->
            { shaped | shape = Circle { data | p = p } }


updatePosition : Vec2 -> WithShape a -> WithShape a
updatePosition p ({ shape } as shaped) =
    case shape of
        AABB (AabbData data) ->
            { shaped | shape = createAABB { data | p = Vec2.add data.p p } }

        Point data ->
            { shaped | shape = Point { p = Vec2.add data.p p } }

        Circle data ->
            { shaped | shape = Circle { data | p = Vec2.add data.p p } }


createAABB : { a | p : Vec2, xw : Vec2, yw : Vec2 } -> Shape
createAABB { p, xw, yw } =
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



-- boolean : Shape -> Shape -> Bool
-- boolean a b =
--     response a b /= Nothing


response : WithShape a -> WithShape b -> Maybe Vec2
response a b =
    case ( a.shape, b.shape ) of
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
