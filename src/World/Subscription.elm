module World.Subscription exposing (gamePad, keyboard)

import Array
import Browser.Events
import Dict
import Json.Decode as Decode
import Logic.Entity as Entity exposing (EntityID)
import Set exposing (Set)
import World.Component.Util exposing (boolToFloat)


gamePad ( gamepadDown, gamepadUp ) port_ world =
    gamepadDown
        (\income ->
            let
                _ =
                    income
                        |> Decode.decodeValue Decode.string

                --                        |> Debug.log "gamePad msg"
            in
            world
        )


keyboard world =
    Sub.batch
        [ Browser.Events.onKeyDown (onKeyDown world)
        , Browser.Events.onKeyUp (onKeyUp world)
        ]


onKeyDown ( world1, { direction } as world2 ) =
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered direction)
        |> Decode.andThen
            (\key ->
                Set.insert key direction.pressed
                    |> updateKeys key ( world1, world2 )
            )


onKeyUp ( world1, { direction } as world2 ) =
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered direction)
        |> Decode.andThen
            (\key ->
                Set.remove key direction.pressed
                    |> updateKeys key ( world1, world2 )
            )


isRegistered direction key =
    --TODO maybe get rid of it and extend more updateKeys to fail in Maybe..
    if Dict.member key direction.registered then
        Decode.succeed key

    else
        Decode.fail "not registered key"


updateKeys keyChanged ( world1, { direction } as world2 ) pressed =
    if world2.direction.pressed == pressed then
        Decode.fail "nothing chnaged"

    else
        let
            newComps =
                direction.registered
                    |> Dict.get keyChanged
                    |> Maybe.andThen
                        (\id ->
                            Array.get id direction.comps
                                |> Maybe.andThen identity
                                |> Maybe.map
                                    (\comp ->
                                        let
                                            { x, y } =
                                                arrows comp pressed
                                        in
                                        Entity.setComponent id { comp | x = x, y = y } direction.comps
                                    )
                        )
                    |> Maybe.withDefault direction.comps

            updatedDirection =
                { direction | comps = newComps }
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


arrows : { a | down : comparable, left : comparable, right : comparable, up : comparable } -> Set comparable -> { x : Float, y : Float }
arrows { up, right, down, left } keys =
    let
        x =
            keyToInt right keys - keyToInt left keys

        y =
            keyToInt up keys - keyToInt down keys
    in
    { x = x, y = y }


keyToInt : comparable -> Set comparable -> Float
keyToInt key =
    Set.member key >> boolToFloat



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
