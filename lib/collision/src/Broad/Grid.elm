module Broad.Grid exposing
    ( Grid
    , NewConfig
    , draw
    , empty
    , empty_
    , fromBytes
    , getConfig
    , insert
    , optimize
    , query
    , setConfig
    , toBytes
    , toList
    )

import Broad exposing (Boundary)
import Bytes exposing (Endianness(..))
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict exposing (Dict)


type alias Grid a =
    ( Dict ( Int, Int ) (Result a)
    , { cols : Int
      , rows : Int
      , xmin : Float
      , ymin : Float
      , cell : ( Float, Float )
      }
    )


toBytes : (a -> Encoder) -> Grid a -> Encoder
toBytes eItem grid =
    let
        list : (a -> Encoder) -> List a -> Encoder
        list f l =
            E.sequence (E.unsignedInt32 BE (List.length l) :: List.map f l)

        items =
            toList grid |> list eItem

        config =
            grid
                |> getConfig
                |> (\{ boundary, cell } ->
                        E.sequence
                            [ E.float32 BE boundary.xmin
                            , E.float32 BE boundary.xmax
                            , E.float32 BE boundary.ymin
                            , E.float32 BE boundary.ymax
                            , E.float32 BE cell.width
                            , E.float32 BE cell.height
                            ]
                   )
    in
    E.sequence [ config, items ]


fromBytes : Decoder ( Broad.Boundary, a1 ) -> Decoder (Grid a1)
fromBytes dItem =
    let
        list decoder =
            D.unsignedInt32 BE
                |> D.andThen (\len -> D.loop ( len, [] ) (listStep decoder))

        listStep decoder ( n, xs ) =
            if n <= 0 then
                D.succeed (D.Done xs)

            else
                D.map (\x -> D.Loop ( n - 1, x :: xs )) decoder

        dBoundary =
            D.map4 (\xmin xmax ymin ymax -> { xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax }) (D.float32 BE) (D.float32 BE) (D.float32 BE) (D.float32 BE)

        dCell =
            D.map2 (\width height -> { width = width, height = height }) (D.float32 BE) (D.float32 BE)

        dConfig =
            D.map2 (\boundary cell -> { boundary = boundary, cell = cell })
                dBoundary
                dCell

        dItems =
            list dItem
    in
    D.map2
        (\config items ->
            List.foldl (\( boundary, item ) acc -> insert boundary item acc) (setConfig config empty) items
        )
        dConfig
        dItems


type alias Config =
    { cellWidth : Float, cellHeight : Float }


type alias NewConfig =
    { boundary : Boundary
    , cell : { width : Float, height : Float }
    }


empty : Grid a
empty =
    empty_ { xmin = 0, ymin = 0, xmax = 0, ymax = 0 } { cellWidth = 0, cellHeight = 0 }


empty_ : Boundary -> Config -> Grid a
empty_ { xmin, xmax, ymin, ymax } config =
    ( Dict.empty
    , { cell = ( config.cellWidth, config.cellHeight )
      , xmin = xmin
      , ymin = ymin
      , cols = abs (xmax - xmin) / config.cellWidth |> ceiling
      , rows = abs (ymax - ymin) / config.cellHeight |> ceiling
      }
    )


toList : Grid a -> List a
toList ( table, _ ) =
    table |> Dict.foldl (\_ -> Dict.union) Dict.empty |> Dict.values


setConfig : NewConfig -> Grid a -> Grid a
setConfig newConfig ( table, config ) =
    let
        { xmin, xmax, ymin, ymax } =
            newConfig.boundary

        cellW =
            newConfig.cell.width

        cellH =
            newConfig.cell.height
    in
    ( table
    , { config
        | xmin = xmin
        , ymin = ymin
        , cols = abs (xmax - xmin) / cellW |> ceiling
        , rows = abs (ymax - ymin) / cellH |> ceiling
        , cell = ( cellW, cellH )
      }
    )


getConfig : Grid a -> NewConfig
getConfig ( _, config ) =
    let
        ( cellW, cellH ) =
            config.cell
    in
    { boundary =
        { xmin = config.xmin
        , xmax = cellW * toFloat config.cols
        , ymin = config.ymin
        , ymax = cellH * toFloat config.rows
        }
    , cell = { width = cellW, height = cellH }
    }


type alias Result a =
    Dict ( ( Float, Float ), ( Float, Float ) ) a


draw f1 f2 ( table, config ) =
    let
        rowList =
            List.range 0 (config.rows - 1)

        colList =
            List.range 0 (config.cols - 1)

        ( cellW, cellH ) =
            config.cell

        rects =
            getAll_ table
                |> Dict.toList
                |> List.map
                    (\( ( ( xmin, ymin ), ( xmax, ymax ) ), _ ) ->
                        f2
                            { x = xmin + (xmax - xmin) / 2
                            , y = ymin + (ymax - ymin) / 2
                            , w = (xmax - xmin) / 2
                            , h = (ymax - ymin) / 2
                            }
                    )

        gridCells =
            List.concatMap
                (\x ->
                    List.map
                        (\y ->
                            f1
                                { x = config.xmin + toFloat x * cellW + cellW * 0.5
                                , y = config.ymin + toFloat y * cellH + cellH * 0.5
                                , w = cellW / 2
                                , h = cellH / 2
                                , active = Dict.member ( x, y ) table
                                }
                        )
                        rowList
                )
                colList
    in
    gridCells ++ rects


insert : Boundary -> a -> Grid a -> Grid a
insert boundary value (( table, config ) as grid) =
    let
        ( ( x11, y11 ), ( x22, y22 ) ) =
            intersectsCellsBoundary boundary grid

        key =
            ( ( boundary.xmin, boundary.ymin ), ( boundary.xmax, boundary.ymax ) )

        newTable =
            List.foldl
                (\cellX acc1 ->
                    List.foldl
                        (\cellY acc2 -> Dict.update ( cellX, cellY ) (setUpdater key value) acc2)
                        acc1
                        (List.range y11 y22)
                )
                table
                (List.range x11 x22)
    in
    ( newTable, config )


setUpdater : ( ( Float, Float ), ( Float, Float ) ) -> a -> (Maybe (Result a) -> Maybe (Result a))
setUpdater k v =
    Maybe.map (Dict.insert k v) >> Maybe.withDefault (Dict.singleton k v) >> Just


optimize : (a -> a -> Maybe a) -> Grid a -> Grid a
optimize combineValue (( table, _ ) as grid) =
    let
        validate ( k1, v1 ) ( k2, v2 ) =
            combine combineValue k1 v1 k2 v2

        apply ( k1, _ ) ( k2, _ ) ( gotCombined, newValue ) acc =
            remove k1 acc
                |> remove k2
                |> insert (keyToBoundary gotCombined) newValue
    in
    foldOverAll_ validate apply ( Dict.toList (getAll_ table), [] ) grid


foldOverAll_ validate apply ( l1, l2 ) acc =
    case l1 of
        a :: rest ->
            innerFoldOverAll_ validate apply a ( rest, [] ) l2 acc
                |> (\( newRest, newAcc, skipped ) ->
                        foldOverAll_ validate apply ( newRest, skipped ) newAcc
                   )

        [] ->
            acc


innerFoldOverAll_ validate apply a ( l1, l2 ) skipped acc =
    case l1 of
        b :: rest ->
            case validate a b of
                Just gotCombined ->
                    innerFoldOverAll_ validate apply gotCombined ( l2 ++ rest, [] ) skipped (apply a b gotCombined acc)

                Nothing ->
                    innerFoldOverAll_ validate apply a ( rest, b :: l2 ) skipped acc

        [] ->
            if List.length skipped > 0 then
                innerFoldOverAll_ validate apply a ( skipped, [] ) [] acc
                    |> (\( newRest, newAcc, newSkipped ) ->
                            ( l2, newAcc, newRest ++ newSkipped )
                       )

            else
                ( l2, acc, a :: skipped )


keyToBoundary ( ( xmin, ymin ), ( xmax, ymax ) ) =
    { xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax }


remove k (( table, config ) as grid) =
    let
        ( ( x11, y11 ), ( x22, y22 ) ) =
            intersectsCellsBoundary (keyToBoundary k) grid

        newTable =
            List.foldl
                (\cellX acc1 ->
                    List.foldl
                        (\cellY ->
                            Dict.update ( cellX, cellY )
                                (Maybe.map (Dict.remove k))
                        )
                        acc1
                        (List.range y11 y22)
                )
                table
                (List.range x11 x22)
    in
    ( newTable, config )


combine canCombine k1 v1 k2 v2 =
    let
        ( ( xmin1, ymin1 ), ( xmax1, ymax1 ) ) =
            k1

        ( ( xmin2, ymin2 ), ( xmax2, ymax2 ) ) =
            k2

        vertically =
            xmin1 == xmin2 && xmax1 == xmax2 && (ymin1 == ymax2 || ymin2 == ymax1)

        horizontally =
            ymin1 == ymin2 && ymax1 == ymax2 && (xmin1 == xmax2 || xmin2 == xmax1)

        combineValue =
            canCombine v1 v2
    in
    if vertically || horizontally then
        combineValue |> Maybe.map (\newValue -> ( ( ( min xmin1 xmin2, min ymin1 ymin2 ), ( max xmax1 xmax2, max ymax1 ymax2 ) ), newValue ))

    else
        Nothing


query : Boundary -> Grid a -> Result a
query boundary (( table, _ ) as grid) =
    let
        ( ( x11, y11 ), ( x22, y22 ) ) =
            intersectsCellsBoundary boundary grid
    in
    List.foldl
        (\cellX acc1 ->
            List.foldl
                (\cellY acc2 ->
                    Dict.get ( cellX, cellY ) table
                        |> Maybe.map (Dict.union acc2)
                        |> Maybe.withDefault acc2
                )
                acc1
                (List.range y11 y22)
        )
        Dict.empty
        (List.range x11 x22)



--queryFold : Boundary -> { x : Float, y : Float } -> Grid a -> Result a
--queryFold { xmin, xmax, ymin, ymax } target ( _, config ) =
--    let
--        ( x22, y22 ) =
--            getCell ( xmin, ymin ) config.cell
--    in
--    Dict.empty


intersectsCellsBoundary : Boundary -> Grid a -> ( ( Int, Int ), ( Int, Int ) )
intersectsCellsBoundary { xmin, xmax, ymin, ymax } ( _, config ) =
    let
        edgeFix =
            --TODO find better solution
            0.0000001

        x1 =
            xmin - config.xmin

        x2 =
            xmax - config.xmin

        y1 =
            ymin - config.xmin

        y2 =
            ymax - config.xmin

        ( x11, y11 ) =
            getCell ( x1, y1 ) config.cell

        ( x22, y22 ) =
            getCell ( x2 - edgeFix, y2 - edgeFix ) config.cell
    in
    ( ( x11, y11 ), ( x22, y22 ) )


getCell : ( Float, Float ) -> ( Float, Float ) -> ( Int, Int )
getCell ( x, y ) cellSize =
    let
        ( cellWidth, cellHeight ) =
            cellSize

        xCell =
            floor (x / cellWidth)

        yCell =
            floor (y / cellHeight)
    in
    ( xCell, yCell )


getAll_ =
    Dict.foldl (\_ -> Dict.union) Dict.empty



--coarse grid
--https://stackoverflow.com/questions/41946007/effiscient-and-wsell-explained-implementation-of-a-quadtree-for-2d-collision-det
--https://0fps.net/2015/01/07/collision-detection-part-1/
