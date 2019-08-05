module Main exposing (main)

import Array
import Base64
import Bytes.Encode
import File exposing (File)
import Html
import Html.Attributes exposing (height, src, style, width)
import Html.Events
import Image exposing (Image)
import Json.Decode as Decode exposing (Decoder)


type Message
    = Drop (List File)
    | DragOver Int


main =
    let
        bmpEncodeBase64 =
            imageData2
                |> Image.encodeBmp
                |> Base64.fromBytes
                |> Maybe.withDefault ""

        pngEncodeBase64 =
            imageData2
                |> Image.encodePng
                |> Base64.fromBytes
                |> Maybe.withDefault ""
    in
    Html.div [ style "background" "grey" ]
        [ Html.img
            [ src ("data:image/bmp;base64," ++ bmpEncodeBase64)
            , width 300
            , height 300
            , style "image-rendering" "pixelated"
            ]
            []
        , Html.img
            [ src ("data:image/png;base64," ++ pngBase64)
            , width 300
            , height 300
            , style "image-rendering" "pixelated"
            ]
            []
        , Html.img
            [ src ("data:image/png;base64," ++ pngEncodeBase64)
            , width 300
            , height 300
            , style "image-rendering" "pixelated"
            ]
            []
        ]


pngBase64 =
    --    "iVBORw0KGgoAAAANSUhEUgAAAG0AAAACCAYAAABSWlLZAAAAF0lEQVR42mNk+M9QzzAKhhRgHI20oQcApUAC//9Je2AAAAAASUVORK5CYII="
    {- 1px -}
    --        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
    {- 2px -}
    --    "iVBORw0KGgoAAAANSUhEUgAAAAIAAAABCAYAAAD0In+KAAAAD0lEQVR42mNk+M9QzwAEAAmGAYCF+yOnAAAAAElFTkSuQmCC"
    {- 3px -}
    --    "iVBORw0KGgoAAAANSUhEUgAAAAMAAAABCAYAAAAb4BS0AAAAD0lEQVR42mNk+M9QzwAFAA+GAYBrzK/eAAAAAElFTkSuQmCC"
    {- 2x2 px -}
    --    "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAEklEQVR42mNk+M9QzwAEjDAGACCDAv8cI7IoAAAAAElFTkSuQmCC"
    "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAAXNSR0IArs4c6QAAABtJREFUCJljXGNk9H/HNAYGhui8h///////HwBKAQoEh008uAAAAABJRU5ErkJggg=="


pngBytes =
    Base64.toBytes pngBase64
        |> Maybe.withDefault (Bytes.Encode.sequence [] |> Bytes.Encode.encode)


imageData1 : Image
imageData1 =
    Image.fromList2d
        [ List.repeat 4 0xFFFF
        , List.repeat 4 0xFF0000FF
        , List.repeat 4 0xFFFF
        , List.repeat 2 0x00FFFFFF
        ]


imageData2 : Image
imageData2 =
    Image.fromArray2d
        ([ List.repeat 4 0x00 |> Array.fromList
         , [ 0xFFFFFFAA ] ++ List.repeat 3 0xFF0000FF |> Array.fromList
         , List.repeat 4 0xFF0000FF |> Array.fromList
         , List.repeat 4 0xFF0000FF |> Array.fromList
         ]
            |> Array.fromList
        )


onDrop =
    Html.Events.custom "drop"
        (Decode.map
            (\f ->
                { message = Drop f
                , stopPropagation = True
                , preventDefault = True
                }
            )
            files
        )


onDragover event i =
    Html.Events.custom event
        (Decode.succeed
            { message = DragOver i
            , stopPropagation = True
            , preventDefault = True
            }
        )



--files : Decoder (Task Error (List ( String, CacheTiled )))


files : Decoder (List File)
files =
    Decode.field "dataTransfer" (Decode.field "files" (Decode.list File.decoder))
