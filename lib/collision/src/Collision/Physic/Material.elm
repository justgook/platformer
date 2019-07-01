module Collision.Physic.Material exposing (Material, bounciness, frictionDynamicDynamic, frictionDynamicStatic)


type alias Material =
    { dFriction : Float
    , sFriction : Float
    , bounciness : Float
    , frictionCombine : Combine
    , bounceCombine : Combine
    }


type Combine
    = Average
    | Minimum
    | Maximum
    | Multiply


frictionDynamicDynamic : Material -> Material -> Float
frictionDynamicDynamic =
    get .frictionCombine .dFriction .dFriction


frictionDynamicStatic : Material -> Material -> Float
frictionDynamicStatic =
    get .frictionCombine .dFriction .sFriction


bounciness : Material -> Material -> Float
bounciness =
    get .bounceCombine .bounciness .bounciness



--https://www.gamedev.net/articles/programming/math-and-physics/combining-material-friction-and-restitution-values-r4227/


get : (Material -> Combine) -> (Material -> Float) -> (Material -> Float) -> Material -> Material -> Float
get f0 f1 f2 a b =
    case union (f0 a) (f0 b) of
        Average ->
            (f1 a + f2 b) * 0.5

        Minimum ->
            min (f1 a) (f2 b)

        Multiply ->
            f1 a * f2 b

        Maximum ->
            max (f1 a) (f2 b)


union : Combine -> Combine -> Combine
union a b =
    if toInt a < toInt b then
        b

    else
        a


toInt a =
    case a of
        Average ->
            0

        Minimum ->
            1

        Multiply ->
            2

        Maximum ->
            3
