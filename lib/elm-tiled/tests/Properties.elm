module Properties exposing (suite)

import Expect
import Generate
import Json.Decode
import Test exposing (..)
import Tiled.Properties exposing (decode, encode)


suite : Test
suite =
    describe "Tiled.Properties"
        [ fuzz Generate.properties "encode / decode" <|
            \obj ->
                obj
                    |> encode
                    |> Json.Decode.decodeValue decode
                    |> Expect.equal (Ok obj)
        ]
