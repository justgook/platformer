module Game.Logic.Direction exposing (Direction(..), fromString, toInt, fromInt)


type Direction
    = North
    | NorthEast
    | East
    | SouthEast
    | South
    | SouthWest
    | West
    | NorthWest
    | NoDirection


fromString : String -> Direction
fromString dir =
    case dir of
        "north" ->
            North

        "N" ->
            North

        "north-east" ->
            NorthEast

        "NE" ->
            NorthEast

        "east" ->
            East

        "E" ->
            East

        "south-east" ->
            SouthEast

        "SE" ->
            SouthEast

        "south" ->
            South

        "S" ->
            South

        "south-west" ->
            SouthWest

        "SW" ->
            SouthWest

        "west" ->
            West

        "W" ->
            West

        "north-west" ->
            NorthWest

        "NW" ->
            NorthWest

        _ ->
            NoDirection


toInt : Direction -> Int
toInt dir =
    case dir of
        North ->
            1

        NorthEast ->
            2

        East ->
            3

        SouthEast ->
            4

        South ->
            5

        SouthWest ->
            6

        West ->
            7

        NorthWest ->
            8

        NoDirection ->
            0


fromInt : Int -> Direction
fromInt dir =
    case dir of
        1 ->
            North

        2 ->
            NorthEast

        3 ->
            East

        4 ->
            SouthEast

        5 ->
            South

        6 ->
            SouthWest

        7 ->
            West

        8 ->
            NorthWest

        _ ->
            NoDirection
