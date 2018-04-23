module Game.Logic.Collision.Map
    exposing
        ( Map
        , cellSize
        , empty
        , getCell
        , insert
        , intersection
        , stepSize
        , table
        )

import Array.Hamt as Array exposing (Array)
import Game.Logic.Collision.Shape as Shape exposing (Shape, WithShape)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- http://www.metanetsoftware.com/2016/n-tutorial-b-broad-phase-collision


type Map a
    = Map
        { table : Table a
        , cellSize : ( Int, Int )
        }


type alias Table a =
    Array (Array (Tile a))


type alias Tile a =
    Maybe (WithShape a)


table : Map a -> Table a
table (Map { table }) =
    table


cellSize : Map a -> ( Int, Int )
cellSize (Map { cellSize }) =
    cellSize


stepSize : Map a -> Float
stepSize (Map { cellSize }) =
    let
        ( w, h ) =
            cellSize
    in
    min (toFloat w / 2) (toFloat h / 2)


get : ( Int, Int ) -> Map a -> Tile a
get ( x, y ) (Map { table }) =
    Array.get y table
        |> Maybe.andThen
            (\row ->
                Array.get x row
            )
        |> Maybe.withDefault Nothing


empty : ( Int, Int ) -> Map a
empty size =
    Map
        { table = Array.empty
        , cellSize = size
        }


insert : WithShape a -> Map a -> Map a
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


intersection : WithShape a -> Map b -> List (WithShape b)
intersection shape ((Map { table, cellSize }) as collisionMap) =
    let
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
                |> List.map (\x -> [ ( x, y1 ), ( x, y2 ) ])
                -- putin corners at the end
                |> reorderCorners
                |> List.concat

        sides =
            List.range y1 y2
                --remove top and bottom corner tiles, they are already added by `topBottomRow`
                |> (List.drop 1 >> List.reverse >> List.drop 1 >> List.reverse)
                |> List.concatMap (\y -> [ ( x1, y ), ( x2, y ) ])
    in
    (sides ++ topBottomRow)
        |> List.foldr
            (\p acc ->
                maybeAdd (get p collisionMap) acc
            )
            []


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


reorderCorners : List a -> List a
reorderCorners list =
    case list of
        [] ->
            []

        a :: b ->
            b ++ [ a ]


maybeAdd : Maybe a -> List a -> List a
maybeAdd item list =
    case item of
        Just data ->
            data :: list

        Nothing ->
            list
