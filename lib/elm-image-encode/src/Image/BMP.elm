module Image.BMP exposing
    ( encode24, encodeWith
    , encodeBytesWith
    )

{-|


# BMP image creating

@docs encode24, encodeWith

-}

-- import BinaryBase64

import Base64 as Base64
import Bitwise exposing (and)
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Decode exposing (Decoder)
import Bytes.Encode as Encode exposing (Encoder, unsignedInt16, unsignedInt32, unsignedInt8)
import Image exposing (ColorDepth(..), Options, Order(..), Pixels, defaultOptions, pixelInt24)


encodeBytesWith : Options a -> Int -> Int -> Bytes -> Bytes
encodeBytesWith { defaultColor, order, depth } w h bytes =
    let
        reverseHorizontal =
            order == RightDown || order == RightUp

        reverseVertical =
            order == LeftDown || order == RightDown

        ( rowLength, pad, bytesPerPixel ) =
            case depth of
                Bit24 ->
                    let
                        bPerPx =
                            3

                        size_ =
                            w * bPerPx

                        pad_ =
                            and (4 - and size_ bPerPx) bPerPx

                        pad__ =
                            unsignedInt8 0
                                |> List.repeat pad_
                                |> Encode.sequence
                    in
                    ( size_, pad__, bPerPx )

        rowCreate =
            Decode.bytes rowLength
                |> Decode.map
                    (\row ->
                        if reverseHorizontal then
                            Encode.sequence
                                [ row
                                    |> Decode.decode (splitToList w (Decode.bytes bytesPerPixel))
                                    |> Maybe.withDefault []
                                    |> List.map Encode.bytes
                                    |> Encode.sequence
                                , pad
                                ]

                        else
                            Encode.sequence
                                [ Encode.bytes row
                                , pad
                                ]
                    )

        pixels_ =
            Decode.decode (splitToList h rowCreate) bytes
                |> Maybe.withDefault []
                |> (if reverseVertical then
                        List.reverse

                    else
                        identity
                   )
                |> Encode.sequence
                |> Encode.encode
    in
    Encode.sequence
        [ Encode.sequence (header w h (Bytes.width pixels_))
        , Encode.bytes pixels_
        ]
        |> Encode.encode


splitToList : Int -> Decoder a -> Decoder (List a)
splitToList len decoder =
    Decode.loop ( len, [] ) (listStep decoder)


listStep : Decoder a -> ( Int, List a ) -> Decoder (Decode.Step ( Int, List a ) (List a))
listStep decoder ( n, xs ) =
    if n <= 0 then
        Decode.succeed (Decode.Done xs)

    else
        Decode.map (\x -> Decode.Loop ( n - 1, x :: xs )) decoder


header : Int -> Int -> Int -> List Encoder
header w h dataSize =
    [ {- BMP Header -}
      -- "BM" -|- ID field ( 42h, 4Dh )
      --   [ 0x42, 0x4D ] |> List.map unsignedInt8
      unsignedInt16 BE 0x424D

    --   70 bytes (54+16) -|- Size of the BMP file
    -- , [ 0x46, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE (54 + dataSize)

    -- -- Unused -|- Application specific
    -- , [ 0x00, 0x00 ] |> List.map
    -- -- Unused -|- Application specific
    -- , [ 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 0

    -- 54 bytes (14+40) -|- Offset where the pixel array (bitmap data) can be found
    -- , [ 0x36, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 54

    {- DIB Header -}
    --40 bytes -|- Number of bytes in the DIB header (from this point)
    -- , [ 0x28, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 40

    -- 2 pixels (left to right order) -|- Width of the bitmap in pixels
    -- , [ 0x02, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE w

    -- 2 pixels (bottom to top order) -|- Height of the bitmap in pixels. Positive for bottom to top pixel order.
    -- , [ 0x02, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE h

    --1 plane -|-  Number of color planes being used
    -- , [ 0x01, 0x00 ] |> List.map unsignedInt8
    , unsignedInt16 LE 1

    -- 24 bits -|- Number of bits per pixel
    -- , [ 0x18, 0x00 ] |> List.map unsignedInt8
    , unsignedInt16 LE 24

    -- 0 -|- BI_RGB, no pixel array compression used
    -- , [ 0x00, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 0

    -- 16 bytes -|- Size of the raw bitmap data (including padding)
    -- , [ 0x10, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 16

    -- 2835 pixels/metre horizontal  | Print resolution of the image, 72 DPI × 39.3701 inches per metre yields 2834.6472
    -- , [ 0x13, 0x0B, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 2835

    -- 2835 pixels/metre vertical
    -- , [ 0x13, 0x0B, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 2835

    -- 0 colors -|- Number of colors in the palette
    -- , [ 0x00, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 0

    -- 0 important colors -|- 0 means all colors are important
    -- , [ 0x00, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 0
    ]


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
    encodeWith { defaultOptions | order = RightUp, depth = Bit24 } w h pixels


{-|

    encodeWith :
        Options
        -> Width
        -> Height
        -> Pixels
        -> Base64String

-}



--https://github.com/ericandrewlewis/bitmap-js/blob/master/index.js


encodeWith : Options a -> Int -> Int -> Pixels -> String
encodeWith opt w h data =
    let
        bytes =
            Encode.encode (List.map pixelInt24 data |> Encode.sequence)

        result =
            encodeBytesWith opt w h bytes

        --        pixels_ =
        --            encodeImageData w opt data
        --                |> Encode.encode
        --
        --        result =
        --            header w h (Bytes.width pixels_)
        --                ++ [ Encode.bytes pixels_ ]
        imageData =
            --            Encode.sequence result
            --                |> Encode.encode
            result
                |> Base64.fromBytes
                |> Maybe.withDefault ""
    in
    "data:image/bmp;base64," ++ imageData
