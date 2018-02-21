module PNGlib exposing (..)

import Bitwise exposing (or, shiftLeftBy, shiftRightBy)
import Html exposing (text)


main =
    text <| toString (shiftLeftBy 4 7)


png =
    -- let
    --     header_ =
    -- ((8 + (7 << 4)) << 8) or (3 << 6)
    --     header =
    --         header_ + 31 - (header_ % 31)
    -- in
    ""
