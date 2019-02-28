module World.DirectionHelper exposing (Direction(..), fromInt, fromString, opposite, toInt, toRecord, toString)


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


opposite : Direction -> Direction
opposite dir =
    case dir of
        North ->
            South

        NorthEast ->
            SouthWest

        East ->
            West

        SouthEast ->
            NorthWest

        South ->
            North

        SouthWest ->
            NorthEast

        West ->
            East

        NorthWest ->
            SouthEast

        NoDirection ->
            NoDirection


toRecord : Direction -> DirectionRecord
toRecord dir =
    case dir of
        North ->
            north

        NorthEast ->
            northEast

        East ->
            east

        SouthEast ->
            southEast

        South ->
            south

        SouthWest ->
            southWest

        West ->
            west

        NorthWest ->
            northWest

        NoDirection ->
            noDirection


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


toString : Direction -> List String
toString dir =
    case dir of
        North ->
            [ "north", "N" ]

        NorthEast ->
            [ "north-east", "NE" ]

        East ->
            [ "east", "E" ]

        SouthEast ->
            [ "south-east", "SE" ]

        South ->
            [ "south", "S" ]

        SouthWest ->
            [ "south-west", "SW" ]

        West ->
            [ "west", "W" ]

        NorthWest ->
            [ "north-west", "NW" ]

        NoDirection ->
            []


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


type alias DirectionRecord =
    { x : Int, y : Int }


north : DirectionRecord
north =
    { x = 0, y = 1 }


northEast : DirectionRecord
northEast =
    { x = 1, y = 1 }


east : DirectionRecord
east =
    { x = 1, y = 0 }


southEast : DirectionRecord
southEast =
    { x = 1, y = -1 }


south : DirectionRecord
south =
    { x = 0, y = -1 }


southWest : DirectionRecord
southWest =
    { x = -1, y = -1 }


west : DirectionRecord
west =
    { x = -1, y = 0 }


northWest : DirectionRecord
northWest =
    { x = -1, y = 1 }


noDirection : DirectionRecord
noDirection =
    { x = 0, y = 0 }
