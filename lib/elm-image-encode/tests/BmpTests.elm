module BmpTests exposing (suite)

import Expect exposing (Expectation)
import Image exposing (Options, Order(..), defaultOptions)
import Image.BMP as BMP
import Test exposing (..)


suite : Test
suite =
    describe "Image"
        [ describe "BMP"
            [ test "Encode 24bit image" <|
                \_ ->
                    [ 0xFF, 0xFF, 0xFF00, 0x0F00 ]
                        |> BMP.encode24 2 2
                        |> Expect.equal "data:image/bmp;base64,Qk1GAAAAAAAAADYAAAAoAAAAAgAAAAIAAAABABgAAAAAABAAAAATCwAAEwsAAAAAAAAAAAAAAA8AAP8AAAD/AAD/AAAAAA=="
            , test "Encode 24bit different order" <|
                \_ ->
                    [ 0xFF, 0xFF, 0xFF00, 0x0F00 ]
                        |> BMP.encodeWith { defaultOptions | order = RightUp } 2 2
                        |> Expect.equal "data:image/bmp;base64,Qk1GAAAAAAAAADYAAAAoAAAAAgAAAAIAAAABABgAAAAAABAAAAATCwAAEwsAAAAAAAAAAAAAAA8AAP8AAAD/AAD/AAAAAA=="
            , test "Encode 24bit with additional bytes" <|
                \_ ->
                    [ 0xFF, 0xFF, 0xFF00, 0x0F00, 0x0F00, 0x0F00 ]
                        |> BMP.encode24 3 2
                        |> Expect.equal "data:image/bmp;base64,Qk1OAAAAAAAAADYAAAAoAAAAAwAAAAIAAAABABgAAAAAABgAAAATCwAAEwsAAAAAAAAAAAAAAA8AAA8AAA8AAAAAAP8A/wAA/wAAAAAA"

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
            --                        |> BMP.encode24 width height
            --                        |> Expect.equal (BMP.encodeWith { defaultOptions | defaultColor = defaultColor, order = RightUp } width height [])
            , test "Encode 24bit should be able encode big images witout call overflow" <|
                \_ ->
                    let
                        defaultColor =
                            0x00

                        width =
                            30

                        height =
                            500

                        _ =
                            List.repeat (width * height) defaultColor
                                |> BMP.encode24 width height
                    in
                    Expect.pass
            ]
        ]
