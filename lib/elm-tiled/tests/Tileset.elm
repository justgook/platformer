module Tileset exposing (suite)

import Expect exposing (Expectation)
import Generate
import Json.Decode
import Json.Encode
import Test exposing (..)
import Tiled.Tileset exposing (Tileset(..), decode, encode)


suite : Test
suite =
    describe "Tiled.Tileset"
        [ fuzz Generate.tileset.source "Source encode / decode" <|
            \obj ->
                obj
                    |> encode
                    |> Json.Decode.decodeValue decode
                    |> Expect.equal (Ok obj)
        , fuzz Generate.tileset.embedded "Embedded encode / decode" <|
            \income ->
                let
                    obj =
                        income
                in
                obj
                    |> encode
                    |> Json.Decode.decodeValue decode
                    |> Expect.equal (Ok obj)
        , fuzz Generate.tileset.imageCollection "ImageCollection encode / decode" <|
            \obj ->
                obj
                    |> encode
                    |> Json.Decode.decodeValue decode
                    |> Expect.equal (Ok obj)
        , test "JSON imageCollection1 decode / encode" <|
            \_ ->
                imageCollection1
                    |> Json.Decode.decodeString decode
                    |> Result.map Tiled.Tileset.encode
                    |> Result.map (expectEqualsJson imageCollection1)
                    |> Result.withDefault (Expect.fail "imageCollection sting is not valid json")
        ]


imageCollection1 =
    """{"columns":0,"firstgid":1, "grid":{"height":1,"orientation":"orthogonal","width":1},"margin":0,"name":"123","spacing":0,"tilecount":1,"tileheight":496,"tiles":[{"id":0,"image":"aa.png","imageheight":496,"imagewidth":496}],"tilewidth":496}"""


expectEqualsJson : String -> Json.Encode.Value -> Expectation
expectEqualsJson string val =
    let
        expected =
            Json.Decode.decodeString Json.Decode.value string
                |> Result.map (Json.Encode.encode 0)
    in
    Json.Encode.encode 0 val
        |> Ok
        |> Expect.equal expected
