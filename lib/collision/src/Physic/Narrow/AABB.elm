module Physic.Narrow.AABB exposing
    ( AABB
    , Collision(..)
    , applyVelocity
    , boundary
    , debuInfo
    , fromBytes
    , getContact
    , getIndex
    , getInvMass
    , getPosition
    , getVelocity
    , isStatic
    , rect
    , response
    , setContact
    , setVelocity
    , toBytes
    , toStatic
    , translate
    , union
    , unionCollision
    , updateVelocity
    , withIndex
    )

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Broad exposing (Boundary)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Direction
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Physic.Narrow.Common as Generic exposing (Generic, Options, defaultOptions)


type AABB comparable
    = AABB (Generic comparable) { h : Float }


toBytes : (Maybe comparable -> Encoder) -> AABB comparable -> Encoder
toBytes enId (AABB c { h }) =
    E.sequence
        [ c.index |> enId
        , c.p |> E.xy
        , c.r |> E.xy
        , c.invMass |> E.float
        , h |> E.float
        ]


fromBytes : Decoder (Maybe comparable) -> Decoder (AABB comparable)
fromBytes deId =
    D.map5
        (\index p r invMass h ->
            AABB
                { index = index
                , p = p
                , r = r
                , invMass = invMass
                , velocity = vec2 0 0
                , contact = vec2 0 0
                }
                { h = h }
        )
        deId
        D.xy
        D.xy
        D.float
        D.float


debuInfo :
    { b
        | circle : Vec2 -> Float -> a
        , ellipse : Vec2 -> Float -> Float -> a
        , rectangle : Vec2 -> Float -> Float -> a
        , radiusRectangle : Vec2 -> Vec2 -> Float -> a
    }
    -> AABB comparable
    -> a
debuInfo draw (AABB o { h }) =
    draw.radiusRectangle o.p o.r h


boundary : AABB comparable -> Boundary
boundary (AABB o { h }) =
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


getIndex : AABB comparable -> Maybe comparable
getIndex body =
    getFromGeneric__ .index body


getPosition : AABB comparable -> Vec2
getPosition body =
    getFromGeneric__ .p body


getVelocity : AABB comparable -> Vec2
getVelocity body =
    getFromGeneric__ .velocity body


applyVelocity : AABB comparable -> AABB comparable
applyVelocity (AABB o a) =
    AABB { o | p = Vec2.add o.p o.velocity } a



--https://github.com/CodingTrain/website
--https://blog.hamaluik.ca/posts/simple-aabb-collision-using-minkowski-difference/
--https://blog.hamaluik.ca/
--https://gafferongames.com/post/collision_response_and_coulomb_friction/
--https://github.com/Apress/building-a-2d-physics-game-engine/blob/master/978-1-4842-2582-0_source%20code/Chapter5/Chapter5.1ACoolDemo/public_html/EngineCore/Physics.js#L84
--https://thebookofshaders.com/08/
--  var minkowski =


minkowskiDifference body1 body2 =
    let
        b1 =
            boundary body1

        b2 =
            boundary body2

        result3 =
            { min =
                { x = b1.xmin - b2.xmax
                , y = b1.ymin - b2.ymax
                }
            , max =
                { x = b1.xmax - b2.xmin
                , y = b1.ymax - b2.ymin
                }
            }
    in
    result3


type Collision
    = X Float
    | Y Float
    | XorY Float Float
    | XandY Float Float
    | None


unionCollision : Collision -> Collision -> Collision
unionCollision a_ b_ =
    case ( a_, b_ ) of
        ( X a, X b ) ->
            X (min a b)

        ( Y a, Y b ) ->
            Y (min a b)

        ( X a, Y b ) ->
            XandY a b

        ( Y a, X b ) ->
            XandY b a

        ( XorY a _, X b ) ->
            X (min a b)

        ( XorY _ a, Y b ) ->
            Y (min a b)

        ( X a, XorY b _ ) ->
            X (min a b)

        ( X a1, XandY a2 b ) ->
            XandY (min a1 a2) b

        ( Y b1, XorY _ b2 ) ->
            Y (min b1 b2)

        ( Y b1, XandY a b2 ) ->
            XandY a (min b1 b2)

        ( XorY a1 b1, XorY a2 b2 ) ->
            XorY (min a1 a2) (min b1 b2)

        ( XorY a1 b1, XandY a2 b2 ) ->
            XandY (min a1 a2) (min b1 b2)

        ( XandY a1 b, X a2 ) ->
            XandY (min a1 a2) b

        ( XandY a b1, Y b2 ) ->
            XandY a (min b1 b2)

        ( XandY a1 b1, XorY a2 b2 ) ->
            XandY (min a1 a2) (min b1 b2)

        ( XandY a1 b1, XandY a2 b2 ) ->
            XandY (min a1 a2) (min b1 b2)

        ( None, a ) ->
            a

        ( a, None ) ->
            a



--type FourBools
--    = FourBools Bool Bool Bool Bool


response body1 body2 =
    let
        md =
            minkowskiDifference body1 body2

        v1 =
            getVelocity body1

        v2 =
            getVelocity body2
    in
    if md.max.x == 0 then
        if md.max.y == 0 then
            --            let
            --                _ =
            --                    Debug.log "XorY" "aaa"
            --            in
            ( XorY 0 0, Direction.northEast )

        else if md.min.y == 0 then
            ( XorY 0 0, Direction.southEast )

        else if v1.x < 0 then
            ( None, Direction.east )

        else
            ( X 0, Direction.east )

    else if md.min.x == 0 then
        if md.max.y == 0 then
            ( XorY 0 0, Direction.northWest )

        else if md.min.y == 0 then
            ( XorY 0 0, Direction.southWest )

        else if v1.x > 0 then
            ( None, Direction.west )

        else
            ( X 0, Direction.west )

    else if md.max.y == 0 && v1.y > 0 then
        ( Y 0, Direction.north )

    else if md.max.y == 0 && v1.y < 0 then
        --next frame after hit celling
        ( None, Direction.north )

    else if md.min.y == 0 then
        if v1.y > 0 then
            ( None, Direction.south )

        else
            ( Y 0, Direction.south )

    else if md.min.x <= 0 && md.max.x >= 0 && md.min.y <= 0 && md.max.y >= 0 then
        --Do they already collide?
        --        let
        --            _ =
        --                Debug.log "should never overlap Separate AS" md
        --        in
        ( XandY 0 0, Direction.neither )

    else
        let
            --            _ =
            --                Debug.log "here" v1
            rv =
                --Relative velocity
                Vec2.sub v1 v2

            --            _ =
            --                Debug.log "something " md
        in
        getRayIntersectionFraction md (vec2 0 0) rv


getRayIntersectionFraction { min, max } origin direction =
    let
        end =
            Vec2.add direction origin

        --TODO add way to for XorY response
        --        minX =
        --            getMin ( X, getRayIntersectionFractionOfFirstRay origin end (vec2 min.x max.y) (vec2 max.x max.y) )
        --                ( X, getRayIntersectionFractionOfFirstRay origin end (vec2 max.x max.y) (vec2 max.x min.y) )
        --
        --        minY =
        --            getMin ( Y, getRayIntersectionFractionOfFirstRay origin end (vec2 max.x min.y) (vec2 min.x min.y) )
        --                ( Y, getRayIntersectionFractionOfFirstRay origin end (vec2 min.x min.y) (vec2 min.x max.y) )
        --
        --  for each of the AABB's four edges
        --  calculate the minimum fraction of "direction"
        --  in order to find where the ray FIRST intersects
        --  the AABB (if it ever does)
        result =
            ( Direction.west, X, getRayIntersectionFractionOfFirstRay origin end (vec2 min.x min.y) (vec2 min.x max.y) )
                |> getMin2 ( Direction.east, X, getRayIntersectionFractionOfFirstRay origin end (vec2 max.x max.y) (vec2 max.x min.y) )
                |> getMin2 ( Direction.south, Y, getRayIntersectionFractionOfFirstRay origin end (vec2 max.x min.y) (vec2 min.x min.y) )
                |> getMin2 ( Direction.north, Y, getRayIntersectionFractionOfFirstRay origin end (vec2 min.x max.y) (vec2 max.x max.y) )
                |> (\( contact, a, b ) ->
                        Maybe.map (\b_ -> ( a b_, contact )) b
                            |> Maybe.withDefault ( None, Direction.neither )
                   )

        --        _ =
        --            Debug.log "getRayIntersectionFraction" result
    in
    --    ( X, getRayIntersectionFractionOfFirstRay origin end (vec2 min.x min.y) (vec2 min.x max.y) )
    --        |> getMin ( X, getRayIntersectionFractionOfFirstRay origin end (vec2 max.x max.y) (vec2 max.x min.y) )
    --        |> getMin ( Y, getRayIntersectionFractionOfFirstRay origin end (vec2 max.x min.y) (vec2 min.x min.y) )
    --        |> getMin ( Y, getRayIntersectionFractionOfFirstRay origin end (vec2 min.x max.y) (vec2 max.x max.y) )
    --        |> (\( a, b ) -> Maybe.map a b |> Maybe.withDefault None)
    result


getMin2 (( _, _, v1 ) as a) (( _, _, v2 ) as b) =
    case ( v1, v2 ) of
        ( Just a_, Just b_ ) ->
            if abs a_ < abs b_ then
                a

            else
                b

        ( Just _, Nothing ) ->
            a

        ( Nothing, Just _ ) ->
            b

        ( Nothing, Nothing ) ->
            a


getMin ( c1, v1 ) ( c2, v2 ) =
    case ( v1, v2 ) of
        ( Just a, Just b ) ->
            if abs a < abs b then
                ( c1, v1 )

            else
                ( c2, v2 )

        ( Just _, Nothing ) ->
            ( c1, v1 )

        ( Nothing, Just _ ) ->
            ( c2, v2 )

        ( Nothing, Nothing ) ->
            ( c1, v1 )



--https://www.youtube.com/watch?v=TOEi6T2mtHo&t=731s


getRayIntersectionFractionOfFirstRay : Vec2 -> Vec2 -> Vec2 -> Vec2 -> Maybe Float
getRayIntersectionFractionOfFirstRay originA endA originB endB =
    let
        perpDotProduct a b =
            a.x * b.y - a.y * b.x

        r =
            Vec2.sub endA originA

        s =
            Vec2.sub endB originB

        numerator =
            perpDotProduct (Vec2.sub originB originA) r

        denominator =
            perpDotProduct r s
    in
    if numerator == 0 && denominator == 0 then
        -- the lines are co-linear
        -- check if they overlap
        -- todo: calculate intersection point
        Nothing

    else if denominator == 0 then
        -- lines are parallel
        Nothing

    else
        let
            u =
                numerator / denominator

            t =
                (Vec2.sub originB originA |> perpDotProduct s) / denominator
        in
        if (t >= 0) && (t <= 1) && (u >= 0) && (u <= 1) then
            Just t

        else
            Nothing


updateVelocity : (Vec2 -> Vec2) -> AABB comparable -> AABB comparable
updateVelocity f body =
    updateGeneric__ (\o -> { o | velocity = f o.velocity }) body


isStatic : AABB comparable -> Bool
isStatic body =
    getFromGeneric__ (.invMass >> (==) 0) body


rect : Float -> Float -> Float -> Float -> AABB comparable
rect x y w h =
    rectWith x y w h defaultOptions


rectWith : Float -> Float -> Float -> Float -> Options comparable -> AABB comparable
rectWith x y w h options =
    AABB
        (Generic.empty (vec2 x y) (vec2 (w / 2) 0) options)
        { h = h / 2 }


setContact : Vec2 -> AABB comparable -> AABB comparable
setContact c body =
    updateGeneric__ (\o -> { o | contact = c }) body


getContact : AABB comparable -> Vec2
getContact body =
    getFromGeneric__ .contact body


setVelocity : Vec2 -> AABB comparable -> AABB comparable
setVelocity v body =
    updateGeneric__ (\o -> { o | velocity = v }) body


toStatic : AABB comparable -> AABB comparable
toStatic body =
    updateGeneric__ (\o -> { o | invMass = 0 }) body


translate : Vec2 -> AABB comparable -> AABB comparable
translate p body =
    updateGeneric__ (\o -> { o | p = Vec2.add o.p p }) body


getInvMass : AABB comparable -> Float
getInvMass body =
    getFromGeneric__ .invMass body


union : AABB comparable -> AABB comparable -> Maybe (AABB comparable)
union ((AABB o1 o11) as body1) ((AABB o2 o22) as body2) =
    let
        b1 =
            boundary body1

        b2 =
            boundary body2

        newShape =
            if o1.p.x == o2.p.x then
                if b1.ymin < b2.ymin then
                    AABB { o1 | p = vec2 o1.p.x ((b2.ymax - b1.ymin) / 2 + b1.ymin) } { h = o11.h + o22.h }

                else
                    AABB { o1 | p = vec2 o1.p.x ((b1.ymax - b2.ymin) / 2 + b2.ymin) } { h = o11.h + o22.h }

            else if b1.xmin < b2.xmin then
                AABB { o1 | p = vec2 ((b2.xmax - b1.xmin) / 2 + b1.xmin) o1.p.y, r = vec2 (o1.r.x + o2.r.x) 0 } { h = o11.h }

            else if b1.xmin > b2.xmin then
                AABB { o1 | p = vec2 ((b1.xmax - b2.xmin) / 2 + b2.xmin) o1.p.y, r = vec2 (o1.r.x + o2.r.x) 0 } { h = o11.h }

            else
                AABB o1 o11
    in
    Just newShape


withIndex : comparable -> AABB comparable -> AABB comparable
withIndex i body =
    updateGeneric__ (\o -> { o | index = Just i }) body


updateGeneric__ : (Generic comparable -> Generic comparable) -> AABB comparable -> AABB comparable
updateGeneric__ f (AABB o a) =
    AABB (f o) a


getFromGeneric__ : (Generic comparable -> a) -> AABB comparable -> a
getFromGeneric__ f (AABB o _) =
    f o
