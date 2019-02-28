module World.Component.Collision exposing (collisions)

import Broad.QuadTree
import Random
import World.Component.Common exposing (EcsSpec, defaultRead)



--collisions : EcsSpec { a | collisions : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)


collisions =
    let
        spec =
            { get = .collisions
            , set = \comps world -> { world | collisions = comps }
            }
    in
    { spec = spec
    , empty = empty --Logic.Component.empty
    , read =
        defaultRead
    }


empty =
    let
        seed0 =
            Random.initialSeed 1420

        --            Random.step
        aabb =
            { x = 300
            , y = 500
            , w = 200
            , h = 450
            }

        tenFractions =
            Random.map2 Tuple.pair
                (Random.float (aabb.x - aabb.w) (aabb.x + aabb.w))
                (Random.float (aabb.y - aabb.h) (aabb.y + aabb.h))
                |> Random.list 500

        qtree =
            Broad.QuadTree.empty 4 aabb

        --                |> Broad.QuadTree.insert ( 200, 200 )
        --                |> Broad.QuadTree.insert ( 300, 200 )
        --                |> Broad.QuadTree.insert ( 400, 200 )
        --                |> Broad.QuadTree.insert ( 500, 200 )
        --                |> Broad.QuadTree.insert ( 500, 250 )
        --                |> Broad.QuadTree.insert ( 500, 250 )
        --                |> Broad.QuadTree.insert ( 500, 251 )
        --                |> Broad.QuadTree.insert ( 500, 252 )
    in
    Random.step tenFractions seed0
        |> Tuple.first
        |> List.foldl Broad.QuadTree.insert qtree
