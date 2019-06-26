module TgaTest exposing (suite)

import Expect exposing (Expectation)
import Image exposing (Options, Order(..), defaultOptions)
import Image.TGA as TGA
import Test exposing (..)


suite : Test
suite =
    describe "Image"
        [ describe "TGA"
            [ test "Encode 24bit image" <|
                \_ ->
                    [ 0xFF, 0xFF, 0xFF00, 0x0F00 ]
                        |> TGA.encode24 20 20
                        |> Expect.equal "data:image/tga;base64,AAACAAAAAAAAAAAAAgACABgAAP8AAA8A/wAA/wAA"

            --            , test "Encode 24bit different order" <|
            --                \_ ->
            --                    [ 0xFF, 0xFF, 0xFF00, 0x0F00 ]
            --                        |> TGA.encodeWith { defaultOptions | order = RightUp } 2 2
            --                        |> Expect.equal "data:image/TGA;base64,Qk1GAAAAAAAAADYAAAAoAAAAAgAAAAIAAAABABgAAAAAABAAAAATCwAAEwsAAAAAAAAAAAAA/wAA/wAAAAAA/wAADwAAAA=="
            --            , test "Encode 24bit with additional bytes" <|
            --                \_ ->
            --                    [ 0xFF, 0xFF, 0xFF00, 0x0F00, 0x0F00, 0x0F00 ]
            --                        |> TGA.encode24 3 2
            --                        |> Expect.equal "data:image/TGA;base64,Qk1OAAAAAAAAADYAAAAoAAAAAwAAAAIAAAABABgAAAAAABAAAAATCwAAEwsAAAAAAAAAAAAA/wAA/wAAAP8AAAAAAA8AAA8AAA8AAAAA"
            --            , test "Encode 24bit with default color" <|
            --                \_ ->
            --                    let
            --                        defaultColor =
            --                            0x00
            --
            --                        width =
            --                            2
            --
            --                        height =
            --                            2
            --                    in
            --                    List.repeat (width * height) defaultColor
            --                        |> TGA.encode24 width height
            --                        |> Expect.equal (TGA.encodeWith { defaultOptions | defaultColor = defaultColor, order = RightUp } width height [])
            --            , test "Encode 24bit should be able encode big images witout call overflow" <|
            --                \_ ->
            --                    let
            --                        defaultColor =
            --                            0x00
            --
            --                        width =
            --                            30
            --
            --                        height =
            --                            500
            --
            --                        _ =
            --                            List.repeat (width * height) defaultColor
            --                                |> TGA.encode24 width height
            --                    in
            --                    Expect.pass
            ]
        ]
