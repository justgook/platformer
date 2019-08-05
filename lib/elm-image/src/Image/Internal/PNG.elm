module Image.Internal.PNG exposing (decode, encode)

--https://www.w3.org/TR/PNG-Structure.html

import Array exposing (Array)
import Bitwise
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder, Step(..))
import Bytes.Encode as E exposing (Encoder)
import Flate exposing (crc32, deflateZlib, inflateZlib)
import Image.Internal.Array2D as Array2d exposing (Array2D)
import Image.Internal.Decode as D
import Image.Internal.ImageData as ImageData exposing (Image(..), Order(..), PixelFormat(..), defaultOptions)


encode : Image -> Bytes
encode imgData =
    let
        opt =
            ImageData.options imgData

        signature =
            E.sequence
                [ E.unsignedInt8 137
                , E.unsignedInt8 80
                , E.unsignedInt8 78
                , E.unsignedInt8 71
                , E.unsignedInt8 13
                , E.unsignedInt8 10
                , E.unsignedInt8 26
                , E.unsignedInt8 10
                ]

        arr =
            ImageData.toArray2d imgData

        height =
            Array.length arr

        width =
            Array.get 0 arr
                |> Maybe.map Array.length
                |> Maybe.withDefault 0

        chunkIHDRType =
            1229472850

        chunkIENDType =
            1229278788

        chunkIDATType =
            1229209940

        chunkIHDR =
            encodeChunk chunkIHDRType (encodeIHDR width height opt |> E.encode)

        chunkIDAT =
            encodeChunk chunkIDATType (encodeIDAT opt arr |> E.encode)

        chunkIEND =
            encodeChunk chunkIENDType (E.sequence [] |> E.encode)
    in
    E.sequence [ signature, chunkIHDR, chunkIDAT, chunkIEND ]
        |> E.encode


encodeChunk : Int -> Bytes -> Encoder
encodeChunk kind data =
    let
        length =
            Bytes.width data

        kindAndData =
            E.encode (E.sequence [ E.unsignedInt32 BE kind, E.bytes data ])
    in
    E.sequence
        [ E.unsignedInt32 BE length
        , E.bytes kindAndData
        , E.unsignedInt32 BE (crc32 kindAndData)
        ]


encodeIDAT : { a | order : Order } -> Array (Array Int) -> Encoder
encodeIDAT { order } arr =
    let
        scanLineFilter =
            E.unsignedInt8 1

        ( fold1, fold2 ) =
            case order of
                RightDown ->
                    ( Array.foldl, Array.foldl )

                RightUp ->
                    ( Array.foldr, Array.foldl )

                LeftDown ->
                    ( Array.foldl, Array.foldr )

                LeftUp ->
                    ( Array.foldr, Array.foldr )
    in
    fold1
        (\sArr acc ->
            fold2
                (\px ( prev, acc2 ) ->
                    let
                        packed =
                            encodePixel32 px prev
                    in
                    ( px, E.sequence [ acc2, packed ] )
                )
                ( 0, scanLineFilter )
                sArr
                |> (\( _, line ) -> E.sequence [ acc, line ])
        )
        (E.sequence [])
        arr
        |> (E.encode >> deflateZlib >> E.bytes)


encodePixel32 : Int -> Int -> Encoder
encodePixel32 px prev =
    let
        r =
            px |> Bitwise.shiftRightZfBy 24

        a =
            px |> Bitwise.and 0xFF

        b =
            px |> Bitwise.shiftRightBy 8 |> Bitwise.and 0xFF

        g =
            px |> Bitwise.shiftRightBy 16 |> Bitwise.and 0xFF

        prevR =
            prev
                |> Bitwise.shiftRightZfBy 24

        prevG =
            prev
                |> Bitwise.shiftRightBy 16
                |> Bitwise.and 0xFF

        prevB =
            prev |> Bitwise.shiftRightBy 8 |> Bitwise.and 0xFF

        prevA =
            prev |> Bitwise.and 0xFF
    in
    packIntoInt32 (r - prevR) (g - prevG) (b - prevB) (a - prevA)
        |> E.unsignedInt32 BE


encodeIHDR : Int -> Int -> { a | format : PixelFormat } -> Encoder
encodeIHDR width height { format } =
    let
        {- 0       1,2,4,8,16  Each pixel is a grayscale sample.

           2       8,16        Each pixel is an R,G,B triple.

           3       1,2,4,8     Each pixel is a palette index;
                               a PLTE chunk must appear.

           4       8,16        Each pixel is a grayscale sample,
                               followed by an alpha sample.

           6       8,16        Each pixel is an R,G,B triple,
                               followed by an alpha sample.
        -}
        ( depth, color ) =
            case format of
                RGBA ->
                    ( 8, 6 )

                RGB ->
                    ( 8, 2 )

                LUMINANCE_ALPHA ->
                    ( 16, 0 )

                ALPHA ->
                    ( 8, 0 )

        --0 (no interlace) or 1 (Adam7 interlace)
        interlace =
            0
    in
    --       Width:              4 bytes
    --       Height:             4 bytes
    --       Bit depth:          1 byte
    --       Color type:         1 byte
    --       Compression method: 1 byte
    --       Filter method:      1 byte
    --       Interlace method:   1 byte
    E.sequence
        [ E.unsignedInt32 BE width
        , E.unsignedInt32 BE height
        , E.unsignedInt8 depth
        , E.unsignedInt8 color
        , E.unsignedInt8 0
        , E.unsignedInt8 0
        , E.unsignedInt8 interlace
        ]


decode : Bytes -> Maybe { width : Int, height : Int, data : Image }
decode bytes =
    let
        chunksLength =
            Bytes.width bytes - 8

        decoder =
            D.listR 8 D.unsignedInt8
                |> D.andThen
                    (\signature ->
                        if signature == [ 10, 26, 10, 13, 71, 78, 80, 137 ] then
                            D.succeed ()

                        else
                            D.fail
                    )
                |> D.andThen (\_ -> chunkLoopR chunksLength decodeChunk)
                |> D.andThen
                    (\image_ ->
                        case image_ of
                            Just image ->
                                case image.data of
                                    ImageData data ->
                                        D.succeed
                                            { width = image.header.width
                                            , height = image.header.height
                                            , data = data
                                            }

                                    _ ->
                                        D.fail

                            _ ->
                                D.fail
                    )
    in
    --137 80 78 71 13 10 26 10
    D.decode decoder bytes


type alias Chunk_ =
    { length : Int
    , kind : Int
    , data : Bytes
    }


type alias PNG =
    { header :
        { width : Int
        , height : Int
        , depth : Int
        , color : Int
        , compression : Int
        , filter : Int
        , interlace : Int
        }
    , data : Pixels
    }


type Pixels
    = None
    | Collecting Encoder
    | ImageData Image


decodeChunk : Maybe PNG -> Decoder ( Int, Maybe PNG )
decodeChunk acc =
    D.unsignedInt32 BE
        |> D.andThen
            (\length ->
                D.map2
                    (\kindAndData crc ->
                        if crc32 kindAndData == crc then
                            D.decode
                                (D.andThen (chunkCollector length acc) (D.unsignedInt32 BE))
                                kindAndData
                                |> Maybe.map D.succeed
                                |> Maybe.withDefault D.fail
                                -- `length` 4-byte unsigned integer giving the number of bytes in the chunk's data field.
                                -- The length counts only the data field, not itself, the chunk type code, or the CRC.
                                |> D.map (Tuple.pair (length + 12))

                        else
                            D.fail
                    )
                    (D.bytes (length + 4))
                    (D.unsignedInt32 BE)
            )
        |> D.andThen identity
        |> D.andThen
            (\( length, chunk ) ->
                D.succeed ( length, chunk )
            )


chunkCollector : Int -> Maybe PNG -> Int -> Decoder (Maybe PNG)
chunkCollector length acc kind =
    --    let
    --        chunkIHDR =
    --            1229472850
    --
    --        chunkIDAT =
    --            1229209940
    --
    --        chunkIEND =
    --            1229278788
    --    in
    case ( acc, kind, length ) of
        ( Nothing, 1229472850, 13 ) ->
            decodeIHDR
                |> D.map Just

        ( Just image, 1229209940, _ ) ->
            decodeIDAT image length
                |> D.map Just

        ( Just image, 1229278788, _ ) ->
            decodeIEND image length
                |> D.map Just

        ( Just image, _, _ ) ->
            decodeUnknown kind image length
                |> D.map Just

        _ ->
            D.fail


decodeIDAT : PNG -> Int -> Decoder PNG
decodeIDAT image length =
    D.bytes length
        |> D.map
            (\b ->
                case image.data of
                    Collecting e ->
                        { image | data = Collecting (E.sequence [ e, E.bytes b ]) }

                    None ->
                        { image | data = Collecting (E.bytes b) }

                    ImageData _ ->
                        image
            )


decodeIEND : PNG -> Int -> Decoder PNG
decodeIEND ({ header } as image) length =
    D.bytes length
        |> D.andThen
            (\_ ->
                case image.data of
                    Collecting e ->
                        let
                            bytes =
                                E.encode e

                            total =
                                Bytes.width bytes

                            decoder =
                                dataDecoder header.width header.height total
                        in
                        D.succeed { image | data = ImageData (Bytes defaultOptions decoder bytes) }

                    _ ->
                        D.fail
            )


dataDecoder : Int -> Int -> Int -> Decoder Image
dataDecoder width height total =
    D.bytes total
        |> D.andThen
            (\bytes ->
                let
                    {- 0       1,2,4,8,16  Each pixel is a grayscale sample.

                       2       8,16        Each pixel is an R,G,B triple.

                       3       1,2,4,8     Each pixel is a palette index;
                                           a PLTE chunk must appear.

                       4       8,16        Each pixel is a grayscale sample,
                                           followed by an alpha sample.

                       6       8,16        Each pixel is an R,G,B triple,
                                           followed by an alpha sample.
                    -}
                    pxDecode =
                        pixelDecode32
                in
                bytes
                    |> inflateZlib
                    |> Maybe.andThen (D.decode (decodeImageData pxDecode width height))
                    |> Maybe.map (Array2d defaultOptions >> D.succeed)
                    |> Maybe.withDefault D.fail
            )


decodeImageData : (Int -> Array2D a -> Decoder (Array2D a)) -> Int -> Int -> Decoder (Array2D a)
decodeImageData pxDecode width height =
    D.foldl height (decodeLine pxDecode width) Array.empty


decodeLine : (Int -> Array2D a -> Decoder (Array2D a)) -> Int -> Array2D a -> Decoder (Array2D a)
decodeLine pxDecode width acc =
    D.unsignedInt8
        |> D.andThen
            (\filterType ->
                D.foldl width (pxDecode filterType) (Array.push Array.empty acc)
            )


pixelDecode32 : Int -> Array2D Int -> Decoder (Array2D Int)
pixelDecode32 filterType acc =
    D.map4
        (\a_ b_ g_ r_ ->
            let
                prev =
                    Array2d.last acc
                        |> Maybe.withDefault 0

                prevA =
                    prev |> Bitwise.and 0xFF

                prevB =
                    prev |> Bitwise.shiftRightBy 8 |> Bitwise.and 0xFF

                prevG =
                    prev |> Bitwise.shiftRightBy 16 |> Bitwise.and 0xFF

                prevR =
                    prev |> Bitwise.shiftRightZfBy 24

                a =
                    a_ + prevA * filterType

                b =
                    b_ + prevB * filterType

                g =
                    g_ + prevG * filterType

                r =
                    r_ + prevR * filterType
            in
            Array2d.push (packIntoInt32 r g b a) acc
        )
        D.unsignedInt8
        D.unsignedInt8
        D.unsignedInt8
        D.unsignedInt8


decodeUnknown : Int -> b -> Int -> Decoder b
decodeUnknown kind image length =
    D.bytes length
        |> D.map
            (\_ ->
                let
                    _ =
                        E.encode (E.unsignedInt32 BE kind)
                            |> D.decode (D.string 4)

                    --                            |> Debug.log "kind"
                in
                image
            )


{-|

    Width:              4 bytes
    Height:             4 bytes
    Bit depth:          1 byte
    Color type:         1 byte
    Compression method: 1 byte
    Filter method:      1 byte
    Interlace method:   1 byte

-}
decodeIHDR : Decoder PNG
decodeIHDR =
    D.succeed
        (\width height depth color compression filter interlace ->
            { header =
                { width = width
                , height = height
                , depth = depth
                , color = color
                , compression = compression
                , filter = filter
                , interlace = interlace
                }
            , data = None
            }
        )
        |> D.andMap (D.unsignedInt32 BE)
        |> D.andMap (D.unsignedInt32 BE)
        |> D.andMap D.unsignedInt8
        |> D.andMap D.unsignedInt8
        |> D.andMap D.unsignedInt8
        |> D.andMap D.unsignedInt8
        |> D.andMap D.unsignedInt8


chunkLoopR : number -> (Maybe a -> Decoder ( number, Maybe a )) -> Decoder (Maybe a)
chunkLoopR length decoder =
    let
        listStep decoder_ ( length_, acc ) =
            decoder_ acc
                |> D.map
                    (\( bytesTaken, newAcc ) ->
                        if length_ - bytesTaken > 0 then
                            Loop ( length_ - bytesTaken, newAcc )

                        else
                            Done newAcc
                    )
    in
    D.loop ( length, Nothing ) (listStep decoder)


packIntoInt32 : Int -> Int -> Int -> Int -> Int
packIntoInt32 r g b a =
    Bitwise.or
        (Bitwise.or
            (Bitwise.shiftLeftBy 24 (Bitwise.and 0xFF r))
            (Bitwise.shiftLeftBy 16 (Bitwise.and 0xFF g))
        )
        (Bitwise.or
            (Bitwise.shiftLeftBy 8 (Bitwise.and 0xFF b))
            (Bitwise.and 0xFF a)
        )



--        |> Bitwise.shiftRightZfBy 0
--        |> Bitwise.and 0xFFFFFFFF
