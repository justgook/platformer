module Direction exposing
    ( Direction(..)
    , DirectionRecord
    , east
    , fromInt
    , fromRecord
    , fromString
    , neither
    , north
    , northEast
    , northWest
    , opposite
    , oppositeMirror
    , south
    , southEast
    , southWest
    , toInt
    , toRecord
    , toString
    , west
    )


type Direction
    = North
    | NorthEast
    | East
    | SouthEast
    | South
    | SouthWest
    | West
    | NorthWest
    | Neither


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

        Neither ->
            Neither


oppositeMirror : Direction -> DirectionRecord
oppositeMirror dir =
    case dir of
        North ->
            { x = 0, y = 1 }

        NorthEast ->
            { x = 1, y = 1 }

        East ->
            { x = 1, y = 0 }

        SouthEast ->
            { x = 1, y = 1 }

        South ->
            { x = 0, y = 1 }

        SouthWest ->
            { x = 1, y = 1 }

        West ->
            { x = 1, y = 0 }

        NorthWest ->
            { x = 1, y = 1 }

        Neither ->
            { x = 0, y = 0 }


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

        Neither ->
            neither


fromRecord : { a | x : Float, y : Float } -> Direction
fromRecord { x, y } =
    if x > 0 then
        if y > 0 then
            NorthEast

        else if y < 0 then
            SouthEast

        else
            East

    else if x < 0 then
        if y > 0 then
            NorthWest

        else if y < 0 then
            SouthWest

        else
            West

    else if y > 0 then
        North

    else if y < 0 then
        South

    else
        Neither


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
            Neither


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

        Neither ->
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

        Neither ->
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
            Neither


type alias DirectionRecord =
    { x : Float, y : Float }


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


neither : DirectionRecord
neither =
    { x = 0, y = 0 }
