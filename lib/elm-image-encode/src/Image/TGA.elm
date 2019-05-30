module Image.TGA exposing (encode24, header)

import Base64 as Base64
import Bytes exposing (Endianness(..))
import Bytes.Encode as Encode exposing (Encoder, unsignedInt16, unsignedInt32, unsignedInt8)
import Image exposing (ColorDepth(..), Options, Order(..), Pixels)



--http://www.paulbourke.net/dataformats/tga/
-- putc(0,fptr);
--   putc(0,fptr);
--   putc(2,fptr);                         /* uncompressed RGB */
--   putc(0,fptr); putc(0,fptr);
--   putc(0,fptr); putc(0,fptr);
--   putc(0,fptr);
--   putc(0,fptr); putc(0,fptr);           /* X origin */
--   putc(0,fptr); putc(0,fptr);           /* y origin */
--   putc((width & 0x00FF),fptr);
--   putc((width & 0xFF00) / 256,fptr);
--   putc((height & 0x00FF),fptr);
--   putc((height & 0xFF00) / 256,fptr);
--   putc(24,fptr);                        /* 24 bit bitmap */
--   putc(0,fptr);


header : Int -> Int -> Int -> List Encoder
header w h dataSize =
    [ unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0x02
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt16 BE 0x00 -- X origin
    , unsignedInt16 BE 0x00 -- y origin
    , unsignedInt16 BE 0x02 -- width
    , unsignedInt16 BE 0x02 -- height
    , unsignedInt8 0x18 --/* 24 bit bitmap */
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0xFF
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0x0F
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    , unsignedInt8 0xFF
    , unsignedInt8 0x00
    , unsignedInt8 0x00
    ]


delme =
    [ 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0x18, 0, 0, 0xFF, 0, 0, 0x0F, 0, 0xFF, 0, 0, 0xFF, 0, 0 ]


data l =
    List.map (unsignedInt32 LE) l


encode24 : Int -> Int -> Pixels -> String
encode24 w h pixels =
    let
        --        pixels_ =
        --            data pixels
        --                |> Encode.sequence
        --                |> Encode.encode
        --                ++ [ Encode.bytes pixels_ ]
        imageData =
            delme
                |> List.map unsignedInt8
                |> Encode.sequence
                |> Encode.encode
                |> Base64.fromBytes
                |> Maybe.withDefault ""
    in
    "data:image/tga;base64," ++ imageData
