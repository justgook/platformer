module Object exposing (suite)

import Expect
import Generate
import Json.Decode
import Test exposing (..)
import Tiled.Object exposing (decode, encode)


suite : Test
suite =
    describe "Tiled.Object"
        [ fuzz Generate.object "encode / decode" <|
            \obj ->
                obj
                    |> encode
                    |> Json.Decode.decodeValue decode
                    |> Expect.equal (Ok obj)
        ]
