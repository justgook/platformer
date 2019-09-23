module Tiled exposing
    ( decode, encode
    , gidInfo, GidInfo
    )

{-| Use the [`decode`](#decode) to get [`Level`](Tiled-Level)


# Default Decoding

@docs decode, encode


# Helpers

@docs gidInfo, GidInfo

-}

import Bitwise
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



-- http://doc.mapeditor.org/en/latest/reference/tmx-map-format/#tile-flipping


{-| -}
type alias GidInfo =
    { gid : Int
    , fh : Bool
    , fv : Bool
    , fd : Bool
    }


{-| The highest three bits of the `gid` store the flipped states. Bit 32 is used for storing whether the tile is horizontally flipped, bit 31 is used for the vertically flipped tiles and bit 30 indicates whether the tile is flipped (anti) diagonally, enabling tile rotation. These bits have to be read and cleared before you can find out which tileset a tile belongs to.
-}
gidInfo : Int -> GidInfo
gidInfo gid =
    { gid = cleanGid gid
    , fh = flippedHorizontally gid
    , fv = flippedVertically gid
    , fd = flippedDiagonally gid
    }


flippedHorizontally : Int -> Bool
flippedHorizontally globalTileId =
    Bitwise.and globalTileId flippedHorizontalFlag /= 0


flippedVertically : Int -> Bool
flippedVertically globalTileId =
    Bitwise.and globalTileId flippedVerticalFlag /= 0


flippedDiagonally : Int -> Bool
flippedDiagonally globalTileId =
    Bitwise.and globalTileId flippedDiagonalFlag /= 0


cleanGid : Int -> Int
cleanGid globalTileId =
    flippedHorizontalFlag
        |> Bitwise.or flippedVerticalFlag
        |> Bitwise.or flippedDiagonalFlag
        |> Bitwise.complement
        |> Bitwise.and globalTileId


flippedHorizontalFlag : Int
flippedHorizontalFlag =
    0x80000000


flippedVerticalFlag : Int
flippedVerticalFlag =
    0x40000000


flippedDiagonalFlag : Int
flippedDiagonalFlag =
    0x20000000
