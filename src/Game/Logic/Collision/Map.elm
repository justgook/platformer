module Game.Logic.Collision.Map exposing (Map, empty, insert, intersection, table)

import Array exposing (Array)
import Game.Logic.Collision.Shape as Shape exposing (Shape)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- http://www.metanetsoftware.com/2016/n-tutorial-b-broad-phase-collision


type Map
    = Map
        { table : Array (Array (Maybe Shape))
        , cellSize : ( Int, Int )
        }


table : Map -> Array (Array (Maybe Shape))
table (Map { table }) =
    table


get : ( Int, Int ) -> Map -> Maybe Shape
get ( x, y ) (Map { table }) =
    Array.get y table
        |> Maybe.andThen
            (\row ->
                Array.get x row
            )
        |> Maybe.withDefault Nothing


intersection : Shape -> Map -> List Shape
intersection shape ((Map { table, cellSize }) as collisionMap) =
    let
        dropFirstLast items =
            items |> List.drop 2 |> List.reverse |> List.drop 2 |> List.reverse

        { p, xw, yw } =
            Shape.aabbData shape

        sum =
            Vec2.add xw yw

        ( x1, y1 ) =
            Vec2.sub p sum
                |> flip getCell cellSize

        ( x2, y2 ) =
            Vec2.add p sum
                |> flip getCell cellSize

        topBottomRow =
            List.range x1 x2
                |> List.concatMap (\x -> [ ( x, y1 ), ( x, y2 ) ])

        sides =
            List.range y1 y2
                |> dropFirstLast
                |> List.concatMap (\y -> [ ( x1, y ), ( x2, y ) ])
    in
    (topBottomRow ++ sides)
        |> List.foldr
            (\p acc ->
                maybeAdd (get p collisionMap) acc
            )
            []


maybeAdd : Maybe a -> List a -> List a
maybeAdd item list =
    case item of
        Just data ->
            data :: list

        Nothing ->
            list


getCell : Vec2 -> ( Int, Int ) -> ( Int, Int )
getCell p cellSize =
    let
        ( x, y ) =
            Vec2.toTuple p

        ( cellWidth, cellHeight ) =
            cellSize

        xCell =
            (x / toFloat cellWidth)
                |> floor

        yCell =
            (y / toFloat cellHeight)
                |> floor
    in
    ( xCell, yCell )


insert : Shape -> Map -> Map
insert shape (Map ({ cellSize, table } as data)) =
    let
        p =
            Shape.position shape

        ( xCell, yCell ) =
            getCell p cellSize

        newTable =
            if Array.length table < (yCell + 1) then
                Array.repeat ((yCell + 1) - Array.length table) Array.empty
                    |> Array.append table
            else
                table

        newTable2 =
            Array.get yCell newTable
                |> Maybe.map
                    (\row ->
                        if Array.length row < (xCell + 1) then
                            Array.repeat ((xCell + 1) - Array.length row) Nothing
                                |> Array.append row
                        else
                            row
                    )
                |> Maybe.map
                    (\row ->
                        Array.set xCell (Just shape) row
                    )
                |> Maybe.map (flip (Array.set yCell) newTable)
                |> Maybe.withDefault newTable
    in
    case shape of
        _ ->
            Map { data | table = newTable2 }


empty : ( Int, Int ) -> Map
empty size =
    Map
        { table = Array.empty
        , cellSize = size
        }
