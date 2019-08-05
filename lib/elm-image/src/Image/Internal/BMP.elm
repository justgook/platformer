module Image.Internal.BMP exposing (decode, encode)

import Bitwise exposing (and)
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder, Step(..))
import Bytes.Encode as E exposing (Encoder, unsignedInt16, unsignedInt32, unsignedInt8)
import Image.Internal.Decode as D exposing (andMap)
import Image.Internal.Encode exposing (unsignedInt24)
import Image.Internal.ImageData as ImageData exposing (Image(..), Order(..), PixelFormat(..), defaultOptions)


decode : Bytes -> Maybe { width : Int, height : Int, data : Image }
decode bytes =
    let
        decoder =
            D.string 2
                |> D.andThen
                    (\bm ->
                        if bm == "BM" then
                            decodeInfo
                                |> D.andThen
                                    (\info ->
                                        let
                                            decoder_ =
                                                case info.bitsPerPixel of
                                                    32 ->
                                                        Just (decode32 info)

                                                    24 ->
                                                        Just (decode24 info)

                                                    16 ->
                                                        Just (decode16 info)

                                                    _ ->
                                                        Nothing
                                        in
                                        case decoder_ of
                                            Just ddd ->
                                                D.succeed
                                                    { width = info.width
                                                    , height = info.height
                                                    , data = Bytes defaultOptions ddd bytes
                                                    }

                                            _ ->
                                                D.fail
                                    )

                        else
                            D.fail
                    )

        decodeInfo =
            D.succeed
                (\fileSize _ pixelStart dibHeader width height color_planes bitsPerPixel compression dataSize ->
                    { fileSize = fileSize
                    , pixelStart = pixelStart
                    , dibHeader = dibHeader
                    , width = width
                    , height = height
                    , color_planes = color_planes
                    , bitsPerPixel = bitsPerPixel
                    , compression = compression
                    , dataSize = dataSize
                    }
                )
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt16 LE)
                |> andMap (D.unsignedInt16 LE)
                |> andMap (D.unsignedInt32 LE)
                |> andMap (D.unsignedInt32 LE)
    in
    D.decode decoder bytes


encode : Image -> Bytes
encode imageData =
    let
        { format, defaultColor, order } =
            ImageData.options imageData

        bytesPerPixel =
            bytesPerPixel_ format

        size_ w =
            w * bytesPerPixel

        pad_ w =
            let
                improveMe =
                    and (4 - and (size_ w) bytesPerPixel) bytesPerPixel
            in
            if improveMe == 4 then
                0

            else
                improveMe

        pad__ w =
            unsignedInt8 0
                |> List.repeat (pad_ w)

        intToBytes_ =
            intToBytes bytesPerPixel

        width =
            ImageData.width_ imageData

        data =
            ImageData.toList2d imageData
    in
    (List.foldl
        (\row ( height, acc ) ->
            let
                noLimit =
                    (<) width

                ( pxCount_, encodedRow_ ) =
                    encodeRow noLimit intToBytes_ row ( 0, [] )

                padding =
                    width - pxCount_

                ( rowWidth, encodedRow ) =
                    if padding > 0 then
                        encodeRow noLimit
                            intToBytes_
                            (List.repeat padding defaultColor)
                            ( pxCount_, encodedRow_ )

                    else
                        ( pxCount_, encodedRow_ )

                withPaddedBytes =
                    E.sequence
                        [ E.sequence (applyIf (order == RightDown || order == RightUp) List.reverse encodedRow)
                        , E.sequence (pad__ rowWidth)
                        ]
            in
            ( height + 1, withPaddedBytes :: acc )
        )
        ( 0, [] )
        data
        |> Tuple.pair width
    )
        |> (\( w, ( h, body_ ) ) ->
                let
                    body =
                        applyIf (order == RightUp || order == LeftUp) List.reverse body_ |> E.sequence |> E.encode

                    header =
                        if format == RGBA then
                            header32 w h (Bytes.width body)

                        else
                            header16_24 (bitsPerPixel_ format) w h (Bytes.width body)
                in
                E.sequence
                    [ E.sequence header
                    , E.bytes body
                    ]
                    |> E.encode
           )


encodeRow limit f items ( i, acc ) =
    let
        addPx px ( i_, acc2 ) =
            ( i_ + 1, f px :: acc2 )
    in
    case ( limit i, items ) of
        ( False, px :: rest ) ->
            encodeRow limit f rest (addPx px ( i, acc ))

        _ ->
            ( i, acc )


applyIf : Bool -> (a -> a) -> a -> a
applyIf bool f a =
    if bool then
        f a

    else
        a


bytesPerPixel_ : PixelFormat -> number
bytesPerPixel_ format =
    case format of
        RGBA ->
            4

        RGB ->
            3

        LUMINANCE_ALPHA ->
            2

        ALPHA ->
            1


bitsPerPixel_ : PixelFormat -> number
bitsPerPixel_ =
    bytesPerPixel_ >> (*) 8


intToBytes bpp color =
    case bpp of
        1 ->
            unsignedInt8 color

        2 ->
            unsignedInt16 Bytes.LE color

        3 ->
            unsignedInt24 Bytes.LE color

        4 ->
            unsignedInt32 Bytes.LE color

        _ ->
            unsignedInt8 0


header2_4_8 =
    --    To define colors used by the bitmap image data (Pixel array)      Mandatory for color depths ≤ 8 bits
    []


header16_24 : Int -> Int -> Int -> Int -> List Encoder
header16_24 bitsPerPixel w h dataSize =
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
    , unsignedInt32 LE (14 + 40)

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
    , unsignedInt16 LE bitsPerPixel

    -- 0 -|- BI_RGB, no pixel array compression used
    -- , [ 0x00, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE 0

    -- 16 bytes -|- Size of the raw bitmap data (including padding)
    -- , [ 0x10, 0x00, 0x00, 0x00 ] |> List.map unsignedInt8
    , unsignedInt32 LE dataSize

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


header32 : Int -> Int -> Int -> List Encoder
header32 w h dataSize =
    [ {- BMP Header -}
      unsignedInt16 BE 0x424D -- "BM"    ID field (42h, 4Dh)
    , unsignedInt32 LE (122 + dataSize) --  Size of the BMP file
    , unsignedInt32 LE 0 --Unused - Application specific
    , unsignedInt32 LE 122 --122 bytes (14+108) Offset where the pixel array (bitmap data) can be found

    {- DIB Header -}
    , unsignedInt32 LE 108 -- 108 bytes    Number of bytes in the DIB header (from this point)
    , unsignedInt32 LE w -- Width of the bitmap in pixels
    , unsignedInt32 LE h -- Height of the bitmap in pixels
    , unsignedInt16 LE 1 --  Number of color planes being used
    , unsignedInt16 LE 32 -- Number of bits per pixel
    , unsignedInt32 LE 3 -- BI_BITFIELDS, no pixel array compression used
    , unsignedInt32 LE dataSize -- Size of the raw bitmap data (including padding)
    , unsignedInt32 LE 2835 -- 2835 pixels/metre horizontal
    , unsignedInt32 LE 2835 -- 2835 pixels/metre vertical
    , unsignedInt32 LE 0 -- Number of colors in the palette
    , unsignedInt32 LE 0 --important colors (0 means all colors are important)
    , unsignedInt32 LE 0xFF000000 --00FF0000 in big-endian Red channel bit mask (valid because BI_BITFIELDS is specified)
    , unsignedInt32 LE 0x00FF0000 --0000FF00 in big-endian    Green channel bit mask (valid because BI_BITFIELDS is specified)
    , unsignedInt32 LE 0xFF00 --000000FF in big-endian    Blue channel bit mask (valid because BI_BITFIELDS is specified)
    , unsignedInt32 LE 0xFF --FF000000 in big-endian    Alpha channel bit mask
    , unsignedInt32 LE 0x206E6957 --   little-endian "Win "    LCS_WINDOWS_COLOR_SPACE

    --CIEXYZTRIPLE Color Space endpoints    Unused for LCS "Win " or "sRGB"
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0
    , unsignedInt32 LE 0

    -----------
    , unsignedInt32 LE 0 --0 Red Gamma    Unused for LCS "Win " or "sRGB"
    , unsignedInt32 LE 0 --0 Green Gamma    Unused for LCS "Win " or "sRGB"
    , unsignedInt32 LE 0 --0 Blue Gamma    Unused for LCS "Win " or "sRGB"
    ]


decode32 : { a | pixelStart : Int, dataSize : Int, width : Int } -> Decoder Image
decode32 info =
    D.bytes info.pixelStart
        |> D.andThen (\_ -> D.listR (info.dataSize // 4) (D.unsignedInt32 LE))
        |> D.map (List defaultOptions info.width)


decode24 : { a | pixelStart : Int, height : Int, width : Int } -> Decoder Image
decode24 info =
    D.bytes info.pixelStart
        |> D.andThen (\_ -> D.listR info.height (D.listR info.width (D.unsignedInt24 LE)))
        |> D.map (List.concat >> List defaultOptions info.width)


decode16 : { a | pixelStart : Int, height : Int, width : Int } -> Decoder Image
decode16 info =
    D.bytes info.pixelStart
        |> D.andThen (\_ -> D.listR info.height (D.listR info.width (D.unsignedInt16 LE)))
        |> D.map (List.concat >> List defaultOptions info.width)
