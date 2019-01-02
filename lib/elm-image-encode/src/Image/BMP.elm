-- https://en.wikipedia.org/wiki/BMP_file_format
{-
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   | Offset | Size |  Hex Value  |              Value             |                                    Description                                    |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |                                                                    BMP Header                                                                    |
   +--------------------------------------------------------------------------------------------------------------------------------------------------+
   |   0h   |   2  |    42 4D    |              "BM"              |                                ID field (42h, 4Dh)                                |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   2h   |   4  | 46 00 00 00 |        70 bytes (54+16)        |                                Size of the BMP file                               |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   6h   |   2  |    00 00    |             Unused             |                                Application specific                               |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   8h   |   2  |    00 00    |             Unused             |                                Application specific                               |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   Ah   |   4  | 36 00 00 00 |        54 bytes (14+40)        |              Offset where the pixel array (bitmap data) can be found              |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |                                                                    DIB Header                                                                    |
   +--------------------------------------------------------------------------------------------------------------------------------------------------+
   |   Eh   |   4  | 28 00 00 00 |            40 bytes            |                Number of bytes in the DIB header (from this point)                |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   12h  |   4  | 02 00 00 00 | 2 pixels (left to right order) |                           Width of the bitmap in pixels                           |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   16h  |   4  | 02 00 00 00 | 2 pixels (bottom to top order) |      Height of the bitmap in pixels. Positive for bottom to top pixel order.      |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   1Ah  |   2  |    01 00    |             1 plane            |                         Number of color planes being used                         |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   1Ch  |   2  |    18 00    |             24 bits            |                              Number of bits per pixel                             |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   1Eh  |   4  | 00 00 00 00 |                0               |                      BI_RGB, no pixel array compression used                      |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   22h  |   4  | 10 00 00 00 |            16 bytes            |                  Size of the raw bitmap data (including padding)                  |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   26h  |   4  | 13 0B 00 00 |  2835 pixels/metre horizontal  | Print resolution of the image, 72 DPI × 39.3701 inches per metre yields 2834.6472 |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   2Ah  |   4  | 13 0B 00 00 |   2835 pixels/metre vertical   |                                                                                   |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   2Eh  |   4  | 00 00 00 00 |            0 colors            |                          Number of colors in the palette                          |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   32h  |   4  | 00 00 00 00 |       0 important colors       |                          0 means all colors are important                         |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |                                                        Start of pixel array (bitmap data)                                                        |
   +--------------------------------------------------------------------------------------------------------------------------------------------------+
   |   36h  |   3  |   00 00 FF  |             0 0 255            |                                  Red, Pixel (0,1)                                 |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   39h  |   3  |   FF FF FF  |           255 255 255          |                                 White, Pixel (1,1)                                |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   3Ch  |   2  |    00 00    |               0 0              |          Padding for 4 byte alignment (could be a value other than zero)          |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   3Eh  |   3  |   FF 00 00  |             255 0 0            |                                 Blue, Pixel (0,0)                                 |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   41h  |   3  |   00 FF 00  |             0 255 0            |                                 Green, Pixel (1,0)                                |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+
   |   44h  |   2  |    00 00    |               0 0              |          Padding for 4 byte alignment (could be a value other than zero)          |
   +--------+------+-------------+--------------------------------+-----------------------------------------------------------------------------------+

-}
-- https://stackoverflow.com/questions/14963182/how-to-convert-last-4-bytes-in-an-array-to-an-integer


module Image.BMP exposing (encode24, encodeWith)

{-|


# BMP image creating

@docs encode24, encodeWith

-}

-- import BinaryBase64

import Base64 as Base64
import Bitwise exposing (and, shiftRightBy)
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Decode
import Bytes.Encode as Encode exposing (Encoder, unsignedInt16, unsignedInt32, unsignedInt8)
import Image exposing (ColorDepth(..), Options, Order(..), Pixels, defaultOptions)


{-| ##Eexample

shortcut for [`encode24With`](#encode24With) with [`defaultOptions`](#defaultOptions)

    encode24With :
        Width
        -> Height
        -> Pixels
        -> Base64String

-}
encode24 : Int -> Int -> Pixels -> String
encode24 w h pixels =
    encodeWith { defaultOptions | depth = Bit24 } w h pixels


{-|

    encodeWith :
        Options
        -> Width
        -> Height
        -> Pixels
        -> Base64String

-}
encodeWith : Options a -> Int -> Int -> Pixels -> String
encodeWith { defaultColor, depth, order } w h pixels =
    let
        remainder =
            case depth of
                Bit24 ->
                    remainderBy 4 (w * 3)

        pixels_ =
            encodeImageData w depth pixels
                |> Encode.encode

        imageData =
            Encode.sequence
                [ header.bm
                , Encode.unsignedInt32 Bytes.LE (54 + (4 - remainder * h))
                , header.info
                , Encode.unsignedInt32 Bytes.LE w
                , Encode.unsignedInt32 Bytes.LE h
                , header.planes
                , bitsPerPixel depth
                , header.compression
                , Encode.unsignedInt32 BE (Bytes.width pixels_)
                , header.end
                , Encode.bytes pixels_
                ]
                |> Encode.encode
                |> Base64.fromBytes
                |> Maybe.withDefault ""
    in
    "data:image/bmp;base64," ++ imageData


encodeImageData : Int -> ColorDepth -> List Int -> Encoder
encodeImageData w depth pxs =
    case depth of
        Bit24 ->
            portionMap w lineFolder24 [] pxs
                |> Encode.sequence



-- unsignedInt8 0


portionMap : Int -> (List a -> List b) -> List b -> List a -> List b
portionMap w f acc items =
    let
        part =
            List.take w items

        left =
            List.drop w items
    in
    if part == [] then
        acc

    else
        portionMap w f (acc ++ f part) left


lineFolder24 pixelInLineLeft =
    case pixelInLineLeft of
        e1 :: e2 :: e3 :: e4 :: rest ->
            -- TODO add tail elimination
            [ unsignedInt24 Bytes.LE e1
            , unsignedInt24 Bytes.LE e2
            , unsignedInt24 Bytes.LE e3
            , unsignedInt24 Bytes.LE e4
            ]
                ++ lineFolder24 rest

        [ e1, e2, e3 ] ->
            [ unsignedInt24 Bytes.LE e1
            , unsignedInt24 Bytes.LE e2
            , unsignedInt24 Bytes.LE e3
            , unsignedInt8 0x00
            ]

        [ e1, e2 ] ->
            [ unsignedInt24 Bytes.LE e1
            , unsignedInt24 Bytes.LE e2
            , unsignedInt8 0
            , unsignedInt8 0
            ]

        [ e1 ] ->
            [ unsignedInt24 Bytes.LE e1
            , unsignedInt8 0x00
            , unsignedInt8 0x00
            , unsignedInt8 0x00
            ]

        [] ->
            []


bitsPerPixel depth =
    case depth of
        Bit24 ->
            [ unsignedInt8 0x18
            , unsignedInt8 0x00
            ]
                |> Encode.sequence


unsignedInt24 : Endianness -> Int -> Encoder
unsignedInt24 endian num =
    if endian == Bytes.LE then
        Encode.sequence
            [ and num 0xFF |> unsignedInt8
            , shiftRightBy 8 (and num 0xFF00) |> unsignedInt8
            , shiftRightBy 16 (and num 0x00FF0000) |> unsignedInt8
            ]

    else
        Encode.sequence
            [ shiftRightBy 16 (and num 0x00FF0000) |> unsignedInt8
            , shiftRightBy 8 (and num 0xFF00) |> unsignedInt8
            , and num 0xFF |> unsignedInt8
            ]


header =
    { bm =
        [ 0x42, 0x4D ]
            |> List.map unsignedInt8
            |> Encode.sequence
    , info =
        [ 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00 ]
            |> List.map unsignedInt8
            |> Encode.sequence
    , planes =
        unsignedInt16 LE 0x0100
    , compression = unsignedInt32 LE 0x00
    , end =
        [ 0x13
        , 0x0B
        , 0x00
        , 0x00
        , 0x13
        , 0x0B
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        , 0x00
        ]
            |> List.map unsignedInt8
            |> Encode.sequence
    }



--++ good"
--     let
--         remainder =
--             remainderBy 4 (w * 3)
--         result =
--             [ 0x42, 0x4D ]
--                 ++ int32LittleEndian (54 + (4 - remainder * h))
--                 ++ [ 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x36
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x28
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    ]
--                 ++ int32LittleEndian w
--                 ++ int32LittleEndian h
--                 ++ [ 0x01
--                    , 0x00
--                    , 0x18
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x10
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x13
--                    , 0x0B
--                    , 0x00
--                    , 0x00
--                    , 0x13
--                    , 0x0B
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    , 0x00
--                    ]
--                 ++ (case order of
--                         RightUp ->
--                             (pixels ++ List.repeat (w * h - List.length pixels) defaultColor)
--                                 |> lineFolderRight w []
--                         RightDown ->
--                             (List.repeat (w * h - List.length pixels) defaultColor ++ List.reverse pixels)
--                                 |> lineFolderLeft w []
--                         LeftUp ->
--                             (pixels ++ List.repeat (w * h - List.length pixels) defaultColor)
--                                 |> lineFolderLeft w []
--                         LeftDown ->
--                             (List.repeat (w * h - List.length pixels) defaultColor ++ List.reverse pixels)
--                                 |> lineFolderRight w []
--                    )
--         good =
--             "result\n                |> BinaryBase64.encode"
--     in
--     "data:image/bmp;base64," ++ good
-- colorAdder : Int -> List Int -> List Int
-- colorAdder a acc =
--     acc ++ int24LittleEndian a
-- lineFolderLeft : Int -> List Int -> List Int -> List Int
-- lineFolderLeft w acc xs =
--     lineFolder True w acc xs
-- lineFolderRight : Int -> List Int -> List Int -> List Int
-- lineFolderRight w acc xs =
--     lineFolder False w acc xs
-- lineFolder : Bool -> Int -> List Int -> List Int -> List Int
-- lineFolder reverse w acc xs =
--     let
--         folding =
--             if reverse then
--                 List.foldr
--             else
--                 List.foldl
--         lineParser line =
--             -- [e1] -> 3 bytes -> add 1 to get a multiple of 4
--             -- [e1,e2] -> 6 bytes -> add 2 to get a multiple of 4
--             -- [e1,e2,e3] -> 9 bytes -> add 3 to get a multiple of 4
--             -- [e1,e2,e3,e4] -> 12 bytes -> add 0 to get a multiple of 4
--             folding colorAdder [] line ++ List.repeat (List.length line |> remainderBy 4) 0x00
--     in
--     case ( List.take w xs, List.drop w xs ) of
--         ( [], [] ) ->
--             acc
--         ( line, [] ) ->
--             acc ++ lineParser line
--         ( line, rest ) ->
--             lineFolder reverse w (acc ++ lineParser line) rest
-- int24LittleEndian : Int -> List Int
-- int24LittleEndian num =
--     [ and num 0xFF
--     , shiftRightBy 8 (and num 0xFF00)
--     , shiftRightBy 16 (and num 0x00FF0000)
--     ]
-- int32LittleEndian : Int -> List Int
-- int32LittleEndian num =
--     [ and num 0xFF
--     , shiftRightBy 8 (and num 0xFF00)
--     , shiftRightBy 16 (and num 0x00FF0000)
--     , shiftRightBy 24 (and num 0xFF000000)
--     ]
