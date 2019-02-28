module Broad.QuadTree exposing (QuadTree, debug, drawPoints, empty, insert, query)

import Math.Vector2 exposing (vec2)
import Math.Vector3 exposing (vec3)
import Math.Vector4 exposing (Vec4, vec4)
import Set exposing (Set)


drawPoints f ((QuadTree { boundary }) as income) =
    query boundary income
        |> Set.toList
        |> List.map f


debug f ((QuadTree { boundary }) as income) =
    debugDig (debugDig_ f) income []


debugDig f ((QuadTree qTree) as income) acc =
    case qTree.body of
        Leaf points ->
            f qTree.boundary :: acc

        Branch { ne, nw, se, sw } ->
            f qTree.boundary
                :: acc
                |> debugDig f ne
                |> debugDig f nw
                |> debugDig f se
                |> debugDig f sw


debugDig_ f boundary =
    f
        { x = boundary.x
        , y = boundary.y
        , width = boundary.w * 2
        , height = boundary.h * 2
        , color = vec4 1 0 0 1
        , scrollRatio = vec2 1 1
        , transparentcolor = vec3 0 0 0
        }


type alias XY =
    --    { x : Float, y : Float }
    ( Float, Float )


type alias AABB =
    { x : Float
    , y : Float
    , w : Float
    , h : Float
    }



--    p : Vec2, xw : Vec2, yw : Vec2


type Branch b l
    = Branch b
    | Leaf l



--type Either a b
--    = Left a
--    | Right b


type alias Points =
    Set XY


type QuadTree
    = QuadTree
        { capacity : Int
        , boundary : AABB
        , body :
            Branch
                { nw : QuadTree
                , ne : QuadTree
                , sw : QuadTree
                , se : QuadTree
                }
                Points
        }


empty : Int -> AABB -> QuadTree
empty capacity boundary =
    QuadTree
        { capacity = capacity
        , center = boundary
        , body = Leaf Set.empty
        }


insert : XY -> QuadTree -> QuadTree
insert point ((QuadTree qTree) as income) =
    if not (isInQuadTree point income) then
        income

    else
        case qTree.body of
            Leaf points ->
                if Set.size points < qTree.capacity then
                    QuadTree
                        { qTree
                            | body = Leaf (Set.insert point points)
                        }

                else
                    subdivide income (Set.insert point points)

            Branch branches ->
                QuadTree { qTree | body = insertToBranches point branches |> Branch }


subdivide : QuadTree -> Set.Set XY -> QuadTree
subdivide (QuadTree { capacity, boundary }) points =
    let
        { x, y, w, h } =
            boundary

        quad =
            { x = 0, y = 0, w = w / 2, h = h / 2 }
    in
    QuadTree
        { capacity = capacity
        , boundary = boundary
        , body =
            Branch
                (Set.foldl insertToBranches
                    { ne = empty capacity { quad | x = x + w / 2, y = y + h / 2 }
                    , nw = empty capacity { quad | x = x - w / 2, y = y + h / 2 }
                    , se = empty capacity { quad | x = x + w / 2, y = y - h / 2 }
                    , sw = empty capacity { quad | x = x - w / 2, y = y - h / 2 }
                    }
                    points
                )
        }


insertToBranches :
    XY
    -> { ne : QuadTree, nw : QuadTree, se : QuadTree, sw : QuadTree }
    -> { ne : QuadTree, nw : QuadTree, se : QuadTree, sw : QuadTree }
insertToBranches p acc =
    if isInQuadTree p acc.ne then
        { acc | ne = insert p acc.ne }

    else if isInQuadTree p acc.nw then
        { acc | nw = insert p acc.nw }

    else if isInQuadTree p acc.se then
        { acc | se = insert p acc.se }

    else if isInQuadTree p acc.sw then
        { acc | sw = insert p acc.sw }

    else
        let
            _ =
                Debug.log "not in" " branch?"
        in
        acc


intersectsAABB : AABB -> AABB -> Bool
intersectsAABB rect1 rect2 =
    (rect1.x - rect1.w < rect2.x + rect2.w)
        && (rect1.x + rect1.w > rect2.x - rect2.w)
        && (rect1.y - rect1.h < rect2.y + rect2.h)
        && (rect1.h + rect1.y > rect2.y - rect2.h)


query : AABB -> QuadTree -> Set XY
query range (QuadTree qTree) =
    if intersectsAABB range qTree.boundary then
        case qTree.body of
            Leaf points ->
                Set.filter (isIn range) points

            Branch { ne, nw, se, sw } ->
                let
                    delme =
                        query range
                in
                Set.union
                    (Set.union (delme ne) (delme nw))
                    (Set.union (delme se) (delme sw))

    else
        Set.empty


isInQuadTree : XY -> QuadTree -> Bool
isInQuadTree p (QuadTree { boundary }) =
    isIn boundary p


isIn : AABB -> XY -> Bool
isIn { x, y, w, h } ( px, py ) =
    px > x - w && px <= x + w && py > y - h && py <= y + h
