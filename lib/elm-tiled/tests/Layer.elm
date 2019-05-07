module Layer exposing (suite)

import Expect
import Generate
import Json.Decode
import Test exposing (..)
import Tiled.Layer exposing (decode, encode)


suite : Test
suite =
    describe "Tiled.Layer"
        [ fuzz Generate.layer "encode / decode" <|
            \obj ->
                obj
                    |> encode
                    |> Json.Decode.decodeValue decode
                    |> Expect.equal (Ok obj)
        ]
