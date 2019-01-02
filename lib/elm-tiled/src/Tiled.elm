module Tiled exposing (decode, encode)

{-| Use the [`decode`](#decode) to get [`Level`](Tiled-Level)


# Default Decoding

@docs decode, encode

-}

import Json.Decode as Json exposing (Decoder)
import Tiled.Level as Level exposing (Level)


{-| Alias to [`Level.encode`](Tiled.Level#encode)
-}
encode : Level -> Json.Value
encode =
    Level.encode


{-| Alias to [`Level.decode`](Tiled.Level#decode)
-}
decode : Decoder Level
decode =
    Level.decode
