module AltMath.Vector4 exposing
    ( Vec4, vec4
    , getX, getY, getZ, getW, setX, setY, setZ, setW
    , add, sub, negate, scale, dot, normalize, direction
    , length, lengthSquared, distance, distanceSquared
    , toRecord, fromRecord
    )

{-| A high performance linear algebra library using native JS arrays. Geared
towards 3D graphics and use with `Graphics.WebGL`. All vectors are immutable.


# Create

@docs Vec4, vec4


# Get and Set

The set functions create a new copy of the vector, updating a single field.

@docs getX, getY, getZ, getW, setX, setY, setZ, setW


# Operations

@docs add, sub, negate, scale, dot, normalize, direction
@docs length, lengthSquared, distance, distanceSquared


# Conversions

@docs toRecord, fromRecord

-}


{-| Four dimensional vector type
-}
type Vec4
    = Vec4 Float Float Float Float


{-| Creates a new 4-element vector with the given x, y, z, and w values.
-}
vec4 : Float -> Float -> Float -> Float -> Vec4
vec4 =
    Vec4


{-| Extract the x component of a vector.
-}
getX : Vec4 -> Float
getX (Vec4 x y z w) =
    x


{-| Extract the y component of a vector.
-}
getY : Vec4 -> Float
getY (Vec4 x y z w) =
    y


{-| Extract the z component of a vector.
-}
getZ : Vec4 -> Float
getZ (Vec4 x y z w) =
    z


{-| Extract the w component of a vector.
-}
getW : Vec4 -> Float
getW (Vec4 x y z w) =
    w


{-| Update the x component of a vector, returning a new vector.
-}
setX : Float -> Vec4 -> Vec4
setX x (Vec4 _ y z w) =
    Vec4 x y z w


{-| Update the y component of a vector, returning a new vector.
-}
setY : Float -> Vec4 -> Vec4
setY y (Vec4 x _ z w) =
    Vec4 x y z w


{-| Update the z component of a vector, returning a new vector.
-}
setZ : Float -> Vec4 -> Vec4
setZ z (Vec4 x y _ w) =
    Vec4 x y z w


{-| Update the w component of a vector, returning a new vector.
-}
setW : Float -> Vec4 -> Vec4
setW w (Vec4 x y z _) =
    Vec4 x y z w


{-| Convert a vector to a record.
-}
toRecord : Vec4 -> { x : Float, y : Float, z : Float, w : Float }
toRecord (Vec4 x y z w) =
    { x = x, y = y, z = z, w = w }


{-| Convert a record to a vector.
-}
fromRecord : { x : Float, y : Float, z : Float, w : Float } -> Vec4
fromRecord { x, y, z, w } =
    Vec4 x y z w


{-| Vector addition: a + b
-}
add : Vec4 -> Vec4 -> Vec4
add (Vec4 ax ay az aw) (Vec4 bx by bz bw) =
    Vec4 (ax + bx) (ay + by) (az + bz) (aw + bw)


{-| Vector subtraction: a - b
-}
sub : Vec4 -> Vec4 -> Vec4
sub (Vec4 ax ay az aw) (Vec4 bx by bz bw) =
    Vec4 (ax - bx) (ay - by) (az - bz) (aw - bw)


{-| Vector negation: -a
-}
negate : Vec4 -> Vec4
negate (Vec4 ax ay az aw) =
    Vec4 -ax -ay -az -aw


{-| The normalized direction from b to a: (a - b) / |a - b|
-}
direction : Vec4 -> Vec4 -> Vec4
direction a b =
    let
        ((Vec4 x y z w) as c) =
            sub a b

        len =
            length c
    in
    Vec4 (x / len) (y / len) (z / len) (w / len)


{-| The length of the given vector: |a|
-}
length : Vec4 -> Float
length (Vec4 x y z w) =
    sqrt (x * x + y * y + z * z + w * w)


{-| The square of the length of the given vector: |a| \* |a|
-}
lengthSquared : Vec4 -> Float
lengthSquared (Vec4 x y z w) =
    x * x + y * y + z * z + w * w


{-| The distance between two vectors.
-}
distance : Vec4 -> Vec4 -> Float
distance a b =
    length (sub a b)


{-| The square of the distance between two vectors.
-}
distanceSquared : Vec4 -> Vec4 -> Float
distanceSquared a b =
    lengthSquared (sub a b)


{-| A unit vector with the same direction as the given vector: a / |a|
-}
normalize : Vec4 -> Vec4
normalize ((Vec4 x y z w) as v4) =
    let
        len =
            length v4
    in
    Vec4 (x / len) (y / len) (z / len) (w / len)


{-| Multiply the vector by a scalar: s \* v
-}
scale : Float -> Vec4 -> Vec4
scale s (Vec4 x y z w) =
    Vec4 (s * x) (s * y) (s * z) (s * w)


{-| The dot product of a and b
-}
dot : Vec4 -> Vec4 -> Float
dot (Vec4 ax ay az aw) (Vec4 bx by bz bw) =
    ax * bx + ay * by + az * bz + aw * bw
