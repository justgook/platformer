module Collision.Physic.Util exposing (normal, rotateClockwise, scalarProjection)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)


scalarProjection : Vec2 -> Vec2 -> Vec2
scalarProjection a b =
    --    let
    --        normB =
    --            Vec2.normalize b
    --    in
    --    Vec2.scale (Vec2.dot a normB) normB
    -- not using `Math.sqrt`
    Vec2.scale (Vec2.dot a b / Vec2.lengthSquared b) b


normal : Vec2 -> { a : Vec2, b : Vec2 }
normal vec =
    let
        { x, y } =
            vec
                |> Vec2.normalize
                |> Vec2.toRecord
    in
    { a = vec2 -y x
    , b = vec2 y -x
    }


rotateClockwise : Float -> Vec2 -> Vec2
rotateClockwise angle { x, y } =
    let
        sinA =
            sin -angle

        cosA =
            cos angle
    in
    { x = x * cosA - y * sinA
    , y = x * sinA + y * cosA
    }
