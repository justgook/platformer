module Util.KeysToDir exposing (arrows)

import Keyboard.Extra exposing (Key)


arrows : { down : Key, left : Key, right : Key, up : Key } -> List Key -> { x : Int, y : Int }
arrows { up, right, down, left } keys =
    let
        toInt key =
            keys
                |> List.member key
                |> boolToInt

        x =
            toInt right - toInt left

        y =
            toInt up - toInt down
    in
    { x = x, y = y }


boolToInt : Bool -> Int
boolToInt bool =
    if bool then
        1
    else
        0
