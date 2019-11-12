module AltMath.Tuple.Vector2 exposing
    ( Vec2, vec2
    , getX, getY, setX, setY
    , add, sub, negate, scale, dot, normalize, direction, mul
    , length, lengthSquared, distance, distanceSquared
    , toRecord, fromRecord
    )

{-| A high performance linear algebra library using native JS arrays. Geared
towards 3D graphics and use with `Graphics.WebGL`. All vectors are immutable.


# Create

@docs Vec2, vec2


# Get and Set

The set functions create a new copy of the vector, updating a single field.

@docs getX, getY, setX, setY


# Operations

@docs add, sub, negate, scale, dot, normalize, direction, mul
@docs length, lengthSquared, distance, distanceSquared


# Conversions

@docs toRecord, fromRecord

-}


{-| Two dimensional vector type
-}
type alias Vec2 =
    ( Float, Float )


{-| Creates a new 2-element vector with the given values.
-}
vec2 : Float -> Float -> Vec2
vec2 =
    Tuple.pair


{-| Extract the x component of a vector.
-}
getX : Vec2 -> Float
getX =
    Tuple.first


{-| Extract the y component of a vector.
-}
getY : Vec2 -> Float
getY =
    Tuple.second


{-| Update the x component of a vector, returning a new vector.
-}
setX : Float -> Vec2 -> Vec2
setX x ( _, y ) =
    ( x, y )


{-| Update the y component of a vector, returning a new vector.
-}
setY : Float -> Vec2 -> Vec2
setY y ( x, _ ) =
    ( x, y )


{-| Convert a vector to a record.
-}
toRecord : Vec2 -> { x : Float, y : Float }
toRecord ( x, y ) =
    { x = x, y = y }


{-| Convert a record to a vector.
-}
fromRecord : { x : Float, y : Float } -> Vec2
fromRecord { x, y } =
    ( x, y )


{-| Vector addition: a + b
-}
add : Vec2 -> Vec2 -> Vec2
add ( ax, ay ) ( bx, by ) =
    ( ax + bx, ay + by )


{-| Vector subtraction: a - b
-}
sub : Vec2 -> Vec2 -> Vec2
sub ( ax, ay ) ( bx, by ) =
    ( ax - bx, ay - by )


{-| Vector negation: -a
-}
negate : Vec2 -> Vec2
negate ( ax, ay ) =
    ( -ax, -ay )


{-| The normalized direction from b to a: (a - b) / |a - b|
-}
direction : Vec2 -> Vec2 -> Vec2
direction a b =
    let
        (( x, y ) as c) =
            sub a b

        len =
            length c
    in
    ( x / len, y / len )


{-| The length of the given vector: |a|
-}
length : Vec2 -> Float
length ( x, y ) =
    sqrt (x * x + y * y)


{-| The square of the length of the given vector: |a| \* |a|
-}
lengthSquared : Vec2 -> Float
lengthSquared ( x, y ) =
    x * x + y * y


{-| The distance between two vectors.
-}
distance : Vec2 -> Vec2 -> Float
distance a b =
    length (sub a b)


{-| The square of the distance between two vectors.
-}
distanceSquared : Vec2 -> Vec2 -> Float
distanceSquared a b =
    lengthSquared (sub a b)


{-| A unit vector with the same direction as the given vector: a / |a|
-}
normalize : Vec2 -> Vec2
normalize (( x, y ) as v2) =
    let
        len =
            length v2
    in
    ( x / len, y / len )


{-| Multiply the vector by a scalar: s \* v
-}
scale : Float -> Vec2 -> Vec2
scale s ( x, y ) =
    ( s * x, s * y )


{-| The dot product of a and b
-}
dot : Vec2 -> Vec2 -> Float
dot ( ax, ay ) ( bx, by ) =
    ax * bx + ay * by


{-| Multiply the vector by a vector: a \* b
-}
mul : Vec2 -> Vec2 -> Vec2
mul ( ax, ay ) ( bx, by ) =
    ( ax * bx, ay * by )
