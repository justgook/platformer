module AltMath.Tuple.Vector3 exposing
    ( Vec3, vec3, i, j, k
    , getX, getY, getZ, setX, setY, setZ
    , add, sub, negate, scale, dot, cross, normalize, direction
    , length, lengthSquared, distance, distanceSquared
    , toRecord, fromRecord
    )

{-| A high performance linear algebra library using native JS arrays. Geared
towards 3D graphics and use with `Graphics.WebGL`. All vectors are immutable.


# Create

@docs Vec3, vec3, i, j, k


# Get and Set

The set functions create a new copy of the vector, updating a single field.

@docs getX, getY, getZ, setX, setY, setZ


# Operations

@docs add, sub, negate, scale, dot, cross, normalize, direction
@docs length, lengthSquared, distance, distanceSquared


# Conversions

@docs toRecord, fromRecord

-}


{-| Three dimensional vector type
-}
type alias Vec3 =
    ( Float, Float, Float )


{-| Creates a new 3-element vector with the given values.
-}
vec3 : Float -> Float -> Float -> Vec3
vec3 x y z =
    ( x, y, z )


{-| The unit vector &icirc; which points in the x direction: `vec3 1 0 0`
-}
i : Vec3
i =
    ( 1, 0, 0 )


{-| The unit vector &jcirc; which points in the y direction: `vec3 0 1 0`
-}
j : Vec3
j =
    ( 0, 1, 0 )


{-| The unit vector k&#0770; which points in the z direction: `vec3 0 0 1`
-}
k : Vec3
k =
    ( 0, 0, 1 )


{-| Extract the x component of a vector.
-}
getX : Vec3 -> Float
getX ( x, y, z ) =
    x


{-| Extract the y component of a vector.
-}
getY : Vec3 -> Float
getY ( x, y, z ) =
    y


{-| Extract the z component of a vector.
-}
getZ : Vec3 -> Float
getZ ( x, y, z ) =
    z


{-| Update the x component of a vector, returning a new vector.
-}
setX : Float -> Vec3 -> Vec3
setX x ( _, y, z ) =
    ( x, y, z )


{-| Update the y component of a vector, returning a new vector.
-}
setY : Float -> Vec3 -> Vec3
setY y ( x, _, z ) =
    ( x, y, z )


{-| Update the z component of a vector, returning a new vector.
-}
setZ : Float -> Vec3 -> Vec3
setZ z ( x, y, _ ) =
    ( x, y, z )


{-| Convert a vector to a record.
-}
toRecord : Vec3 -> { x : Float, y : Float, z : Float }
toRecord ( x, y, z ) =
    { x = x, y = y, z = z }


{-| Convert a record to a vector.
-}
fromRecord : { x : Float, y : Float, z : Float } -> Vec3
fromRecord { x, y, z } =
    ( x, y, z )


{-| Vector addition: a + b
-}
add : Vec3 -> Vec3 -> Vec3
add ( ax, ay, az ) ( bx, by, bz ) =
    ( ax + bx, ay + by, az + bz )


{-| Vector subtraction: a - b
-}
sub : Vec3 -> Vec3 -> Vec3
sub ( ax, ay, az ) ( bx, by, bz ) =
    ( ax - bx, ay - by, az - bz )


{-| Vector negation: -a
-}
negate : Vec3 -> Vec3
negate ( x, y, z ) =
    ( -x, -y, -z )


{-| The normalized direction from b to a: (a - b) / |a - b|
-}
direction : Vec3 -> Vec3 -> Vec3
direction a b =
    let
        (( x, y, z ) as c) =
            sub a b

        len =
            length c
    in
    ( x / len, y / len, z / len )


{-| The length of the given vector: |a|
-}
length : Vec3 -> Float
length ( x, y, z ) =
    sqrt (x * x + y * y + z * z)


{-| The square of the length of the given vector: |a| \* |a|
-}
lengthSquared : Vec3 -> Float
lengthSquared ( x, y, z ) =
    x * x + y * y + z * z


{-| The distance between two vectors.
-}
distance : Vec3 -> Vec3 -> Float
distance ( ax, ay, az ) ( bx, by, bz ) =
    let
        x =
            ax - bx

        y =
            ay - by

        z =
            az - bz
    in
    sqrt (x * x + y * y + z * z)


{-| The square of the distance between two vectors.
-}
distanceSquared : Vec3 -> Vec3 -> Float
distanceSquared ( ax, ay, az ) ( bx, by, bz ) =
    let
        x =
            ax - bx

        y =
            ay - by

        z =
            az - bz
    in
    x * x + y * y + z * z


{-| A unit vector with the same direction as the given vector: a / |a|
-}
normalize : Vec3 -> Vec3
normalize (( x, y, z ) as v3) =
    let
        len =
            length v3
    in
    ( x / len, y / len, z / len )


{-| Multiply the vector by a scalar: s \* v
-}
scale : Float -> Vec3 -> Vec3
scale s ( x, y, z ) =
    ( s * x, s * y, s * z )


{-| The dot product of a and b
-}
dot : Vec3 -> Vec3 -> Float
dot ( ax, ay, az ) ( bx, by, bz ) =
    ax * bx + ay * by + az * bz


{-| The cross product of a and b
-}
cross : Vec3 -> Vec3 -> Vec3
cross ( ax, ay, az ) ( bx, by, bz ) =
    ( ay * bz - az * by
    , az * bx - ax * bz
    , ax * by - ay * bx
    )
