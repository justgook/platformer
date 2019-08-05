module Image exposing
    ( decode
    , encodeBmp, encodePng
    , fromList, fromList2d, fromArray, fromArray2d, fromBytes
    , toList, toList2d, toArray, toArray2d
    , Image
    , Width, Height
    )

{-|


# Decoding

@docs decode


# Encoding

@docs encodeBmp, encodePng


# Construct

@docs fromList, fromList2d, fromArray, fromArray2d, fromBytes


# Destruct

@docs toList, toList2d, toArray, toArray2d


# Types

@docs Image
@docs Width, Height

-}

import Array exposing (Array)
import Bytes exposing (Bytes)
import Bytes.Decode exposing (Decoder)
import Image.Internal.BMP as BMP
import Image.Internal.ImageData exposing (Image(..), defaultOptions)
import Image.Internal.PNG as PNG
import Maybe exposing (Maybe)


{-| -}
type alias Width =
    Int


{-| -}
type alias Height =
    Int


{-| -}
type alias Image =
    Image.Internal.ImageData.Image


{-| -}
fromList : Width -> List Int -> Image
fromList =
    List defaultOptions


{-| -}
fromList2d : List (List Int) -> Image
fromList2d =
    List2d defaultOptions


{-| -}
fromArray : Width -> Array Int -> Image
fromArray =
    Array defaultOptions


{-| -}
fromArray2d : Array (Array Int) -> Image
fromArray2d =
    Array2d defaultOptions


{-| -}
fromBytes : Decoder Image -> Bytes -> Image
fromBytes =
    Bytes defaultOptions


{-| -}
toList : Image -> List Int
toList =
    Image.Internal.ImageData.toList


{-| -}
toList2d : Image -> List (List Int)
toList2d =
    Image.Internal.ImageData.toList2d


{-| -}
toArray : Image -> Array Int
toArray =
    Image.Internal.ImageData.toArray


{-| -}
toArray2d : Image -> Array (Array Int)
toArray2d =
    Image.Internal.ImageData.toArray2d


{-| Portable Network Graphics (PNG) is a raster-graphics file-format that supports lossless data compression. PNG was developed as an improved, non-patented replacement for Graphics Interchange Format (GIF).

PNG supports palette-based images (with palettes of 24-bit RGB or 32-bit RGBA colors), grayscale images (with or without alpha channel for transparency), and full-color non-palette-based RGB images (with or without alpha channel).

-}
encodePng : Image -> Bytes
encodePng =
    PNG.encode


{-| The BMP file format, also known as bitmap image file or device independent bitmap (DIB) file format or simply a bitmap, is a raster graphics image file format used to store bitmap digital images, independently of the display device (such as a graphics adapter), especially on Microsoft Windows and OS/2 operating systems.

Note: Using BMP 32bit is discouraged due to lack of proper support across browsers

-}
encodeBmp : Image -> Bytes
encodeBmp =
    BMP.encode


{-| -}
decode : Bytes -> Maybe { width : Int, height : Int, data : Image }
decode bytes =
    PNG.decode bytes
        |> or (BMP.decode bytes)


or : Maybe a -> Maybe a -> Maybe a
or ma mb =
    case ma of
        Nothing ->
            mb

        Just _ ->
            ma
