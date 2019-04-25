module Broad.QuadTree exposing (Node, draw, empty, insert, query)

import Broad exposing (Boundary)
import Set exposing (Set)


draw f1 f2 (( _, boundary ) as income) =
    query boundary income
        |> Set.toList
        |> List.map (\( x, y ) -> f2 { x = x, y = y, w = 10, h = 10 })
        |> (++) (debugDig f1 income [])


debugDig f ( Node body, boundary ) acc =
    let
        data =
            { x = boundary.x
            , y = boundary.y
            , w = boundary.w
            , h = boundary.h
            , active = False
            }
    in
    case body of
        Leaf points ->
            f data :: acc

        Branch { ne, nw, se, sw } ->
            let
                delme2 =
                    getBoundary boundary
            in
            f data
                :: acc
                |> debugDig f ( ne, delme2.ne )
                |> debugDig f ( nw, delme2.nw )
                |> debugDig f ( se, delme2.se )
                |> debugDig f ( sw, delme2.sw )


type alias XY =
    ( Float, Float )


type alias AABB =
    { x : Float
    , y : Float
    , w : Float
    , h : Float
    }


type Branch b l
    = Branch b
    | Leaf l



--type Either a b
--    = Left a
--    | Right b


type alias Points =
    Set XY


type alias QuadTree =
    ( Node, AABB )


type Node
    = Node (Branch { nw : Node, ne : Node, sw : Node, se : Node } Points)


capacity =
    4


type alias Config =
    ()


empty : Boundary -> QuadTree
empty { xmin, xmax, ymin, ymax } =
    let
        boundary =
            { x = xmin + xmax / 2
            , y = ymin + ymax / 2
            , w = abs (xmax - xmin) / 2
            , h = abs (ymax - ymin) / 2
            }
    in
    ( Node (Leaf Set.empty), boundary )


insert : XY -> QuadTree -> QuadTree
insert point ( (Node body) as income, aabb ) =
    if not (isIn aabb point) then
        ( income, aabb )

    else
        case body of
            Leaf points ->
                if Set.size points < capacity then
                    ( Node (Leaf (Set.insert point points)), aabb )

                else
                    ( subdivide aabb (Set.insert point points), aabb )

            Branch branches ->
                ( insertToBranches aabb point branches |> Branch |> Node, aabb )


getBoundary boundary =
    let
        { x, y, w, h } =
            boundary

        quad =
            { x = 0, y = 0, w = w / 2, h = h / 2 }
    in
    { ne = { quad | x = x + w / 2, y = y + h / 2 }
    , nw = { quad | x = x - w / 2, y = y + h / 2 }
    , se = { quad | x = x + w / 2, y = y - h / 2 }
    , sw = { quad | x = x - w / 2, y = y - h / 2 }
    }


subdivide : AABB -> Set.Set XY -> Node
subdivide boundary points =
    let
        empty_ =
            Node (Leaf Set.empty)
    in
    Set.foldl (insertToBranches boundary) { ne = empty_, nw = empty_, se = empty_, sw = empty_ } points
        |> Branch
        |> Node


insertToBranches :
    AABB
    -> XY
    -> { ne : Node, nw : Node, se : Node, sw : Node }
    -> { ne : Node, nw : Node, se : Node, sw : Node }
insertToBranches aabb (( px, py ) as point) branches =
    case ( px > aabb.x, py > aabb.y ) of
        ( True, True ) ->
            { branches | ne = insert point ( branches.ne, (getBoundary aabb).ne ) |> Tuple.first }

        ( True, False ) ->
            { branches | se = insert point ( branches.se, (getBoundary aabb).se ) |> Tuple.first }

        ( False, True ) ->
            { branches | nw = insert point ( branches.nw, (getBoundary aabb).nw ) |> Tuple.first }

        ( False, False ) ->
            { branches | sw = insert point ( branches.sw, (getBoundary aabb).sw ) |> Tuple.first }


intersectsAABB : AABB -> AABB -> Bool
intersectsAABB rect1 rect2 =
    (rect1.x - rect1.w < rect2.x + rect2.w)
        && (rect1.x + rect1.w > rect2.x - rect2.w)
        && (rect1.y - rect1.h < rect2.y + rect2.h)
        && (rect1.h + rect1.y > rect2.y - rect2.h)


query : AABB -> QuadTree -> Set XY
query range ( Node body, boundary ) =
    if intersectsAABB range boundary then
        case body of
            Leaf points ->
                Set.filter (isIn range) points

            Branch { ne, nw, se, sw } ->
                let
                    delme2 =
                        getBoundary boundary
                in
                Set.union
                    (Set.union (query range ( ne, delme2.ne )) (query range ( nw, delme2.nw )))
                    (Set.union (query range ( se, delme2.se )) (query range ( sw, delme2.sw )))

    else
        Set.empty


isIn : AABB -> XY -> Bool
isIn { x, y, w, h } ( px, py ) =
    px > x - w && px <= x + w && py > y - h && py <= y + h
