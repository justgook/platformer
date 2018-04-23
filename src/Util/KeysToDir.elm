module Util.KeysToDir exposing (arrows)

import Keyboard.Extra exposing (Key)


arrows : { down : Key, left : Key, right : Key, up : Key } -> List Key -> { x : Int, y : Int }
arrows { up, right, down, left } keys =
    let
        x =
            toInt right keys - toInt left keys

        y =
            toInt up keys - toInt down keys
    in
        { x = x, y = y }


toInt : a -> List a -> Int
toInt key =
    List.member key >> boolToInt


boolToInt : Bool -> Int
boolToInt bool =
    if bool then
        1
    else
        0
