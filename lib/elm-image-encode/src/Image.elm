module Image exposing
    ( Pixels, defaultOptions, Options, Order(..), ColorDepth(..)
    , pixelInt24
    )

{-|


# Options

@docs Pixels, defaultOptions, Options, Order, ColorDepth

-}

import Bytes
import Image.Internal exposing (unsignedInt24)


{-| Pixel render order in image
-}
type Order
    = RightDown
    | RightUp
    | LeftDown
    | LeftUp


{-|

  - 4 16 (Standard VGA)
  - 8 256 (Super VGA, indexed color)
  - 15 32K (option on earlier cards)
  - 16 65K (High Color)
  - 24 16M (True Color)
  - 32 16M (True Color + alpha channel)
  - 30 1B (Deep Color)
  - 36 68B (Deep Color)
  - 48 260T (Deep Color)

-}
type ColorDepth
    = Bit24


type alias Pixels =
    List Int


{-| -}
type alias Options a =
    { a
        | defaultColor : Int
        , order : Order
        , depth : ColorDepth
    }


pixelInt24 e1 =
    unsignedInt24 Bytes.LE e1


{-|

    { defaultColor = 0x00FFFF00
    , order = RightUp
    }

-}
defaultOptions : Options {}
defaultOptions =
    { defaultColor = 0x00FFFF00
    , order = LeftUp
    , depth = Bit24
    }
