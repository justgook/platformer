module Delme exposing (suite)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, optional, required)
import Json.Encode as Encode
import Random
import Test exposing (..)


suite : Test
suite =
    describe "Tiled.Tileset"
        [ fuzz genEmbedded "Embedded encode / decode" <|
            \income ->
                let
                    obj =
                        income
                in
                obj
                    |> encodeEmbeddedTileset
                    -- |> (\d ->
                    --         let
                    --             _ =
                    --                 d
                    --                     |> Encode.encode 0
                    --                     |> Debug.log "hello"
                    --         in
                    --         d
                    --    )
                    |> Decode.decodeValue decodeEmbeddedTileset
                    |> Expect.equal (Ok obj)
        ]


fuzzId : Fuzzer Int
fuzzId =
    Fuzz.intRange 1 Random.maxInt


genEmbedded =
    Fuzz.map EmbeddedTileData
        (Fuzz.tuple ( fuzzId, tilesData_one )
            |> Fuzz.list
            |> Fuzz.map Dict.fromList
        )


encodeEmbeddedTileset data =
    [ ( "tiles", Encode.list encodeTilesData (Dict.toList data.tiles) ) ]
        |> Encode.object


decodeEmbeddedTileset : Decoder EmbeddedTileData
decodeEmbeddedTileset =
    Decode.succeed EmbeddedTileData
        |> optional "tiles" decodeTiles Dict.empty


type alias EmbeddedTileData =
    { tiles : Dict Int TilesData }


type alias TilesData =
    Dict String Int


tilesData_one : Fuzzer TilesData
tilesData_one =
    properties


property : Fuzzer Int
property =
    Fuzz.int


properties : Fuzzer (Dict String Int)
properties =
    Fuzz.tuple ( Fuzz.string, property )
        |> Fuzz.list
        |> Fuzz.map Dict.fromList


decodeTiles =
    Decode.list decodeTilesData
        |> Decode.andThen
            (List.foldl
                (\{ id, props } acc ->
                    acc |> Decode.andThen (Dict.insert id props >> Decode.succeed)
                )
                (Decode.succeed Dict.empty)
            )


decodeTilesData =
    Decode.map2 (\c d -> { props = c, id = d })
        (Decode.maybe (Decode.dict Decode.int) |> Decode.map (Maybe.map (Dict.remove "id")) |> Decode.map (Maybe.withDefault Dict.empty))
        (Decode.field "id" Decode.int)


encodeTilesData ( id, data ) =
    data
        |> Dict.insert "id" id
        |> Encode.dict identity Encode.int
