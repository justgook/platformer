module World.Input exposing (keyboard1)

import Array
import Browser.Events
import Json.Decode as Decode
import Logic.Entity as Entity exposing (EntityID)
import Logic.System
import Set exposing (Set)
import World.Component exposing (defaultRead, inFirst)


spec =
    { get = .direction >> .comps
    , set = \comps ({ direction } as world) -> { world | direction = { direction | comps = comps } }
    }



-- TODO move to component and name it as InputSpec


keyboard1 =
    { sub =
        \world ->
            Sub.batch
                [ Browser.Events.onKeyDown (onKeyDown world)
                , Browser.Events.onKeyUp (onKeyUp world)
                ]
    , spec = spec
    , empty =
        { pressed = Set.empty
        , comps = Array.empty
        , registred =
            Set.fromList [ "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowUp" ]
        }
    , read =
        { defaultRead
            | objectTile =
                \{ x, y } _ _ ->
                    inFirst
                        (Entity.with
                            ( spec
                            , { x = 0
                              , y = 0
                              , down = "ArrowDown"
                              , left = "ArrowLeft"
                              , right = "ArrowRight"
                              , up = "ArrowUp"
                              }
                            )
                        )
        }
    }


onKeyDown ( world1, { direction } as world2 ) =
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistred direction)
        |> Decode.andThen
            (\key ->
                Set.insert key direction.pressed
                    |> updateKeys key ( world1, world2 )
            )


onKeyUp ( world1, { direction } as world2 ) =
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistred direction)
        |> Decode.andThen
            (\key ->
                Set.remove key direction.pressed
                    |> updateKeys key ( world1, world2 )
            )


isRegistred direction key =
    if Set.member key direction.registred then
        Decode.succeed key

    else
        Decode.fail "not registred key"


updateKeys keyChanged ( world1, { direction } as world2 ) pressed =
    if world2.direction.pressed == pressed then
        Decode.fail "nothing chnaged"

    else
        let
            updatedDirection =
                --TODO convert to plain Array.map or something like that, or even better - convert registred from set to dict, where it registers key to EntityID
                Logic.System.map
                    (\comp ->
                        let
                            { x, y } =
                                arrows comp pressed
                        in
                        { comp | x = x, y = y }
                    )
                    spec
                    world2
                    |> .direction
        in
        Decode.succeed
            ( world1
            , { world2
                | direction =
                    { updatedDirection
                        | pressed = pressed
                    }
              }
            )


arrows : { a | down : comparable, left : comparable, right : comparable, up : comparable } -> Set comparable -> { x : Int, y : Int }
arrows { up, right, down, left } keys =
    let
        x =
            keyToInt right keys - keyToInt left keys

        y =
            keyToInt up keys - keyToInt down keys
    in
    { x = x, y = y }


keyToInt : comparable -> Set comparable -> Int
keyToInt key =
    Set.member key >> boolToInt


boolToInt : Bool -> Int
boolToInt bool =
    if bool then
        1

    else
        0



-- type Direction
--     = North
--     | NorthEast
--     | East
--     | SouthEast
--     | South
--     | SouthWest
--     | West
--     | NorthWest
--     | NoDirection
-- fromString : String -> Direction
-- fromString dir =
--     case dir of
--         "north" ->
--             North
--         "N" ->
--             North
--         "north-east" ->
--             NorthEast
--         "NE" ->
--             NorthEast
--         "east" ->
--             East
--         "E" ->
--             East
--         "south-east" ->
--             SouthEast
--         "SE" ->
--             SouthEast
--         "south" ->
--             South
--         "S" ->
--             South
--         "south-west" ->
--             SouthWest
--         "SW" ->
--             SouthWest
--         "west" ->
--             West
--         "W" ->
--             West
--         "north-west" ->
--             NorthWest
--         "NW" ->
--             NorthWest
--         _ ->
--             NoDirection
-- toInt : Direction -> Int
-- toInt dir =
--     case dir of
--         North ->
--             1
--         NorthEast ->
--             2
--         East ->
--             3
--         SouthEast ->
--             4
--         South ->
--             5
--         SouthWest ->
--             6
--         West ->
--             7
--         NorthWest ->
--             8
--         NoDirection ->
--             0
-- fromInt : Int -> Direction
-- fromInt dir =
--     case dir of
--         1 ->
--             North
--         2 ->
--             NorthEast
--         3 ->
--             East
--         4 ->
--             SouthEast
--         5 ->
--             South
--         6 ->
--             SouthWest
--         7 ->
--             West
--         8 ->
--             NorthWest
--         _ ->
--             NoDirection
