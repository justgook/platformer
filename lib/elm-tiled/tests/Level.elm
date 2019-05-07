module Level exposing (..)

import Dict
import Expect exposing (Expectation)
import Json.Decode exposing (decodeString)
import Mock
import Test exposing (..)
import Tiled.Decode as Tiled


suite : Test
suite =
    describe "The Tiled.Decode module"
        [ describe "Tiled.Decode.decode"
            [ test "decode simple level" <|
                \_ ->
                    case decodeString Tiled.decode Mock.bareMinimum of
                        Ok data ->
                            Expect.pass

                        Err err ->
                            Expect.fail err
            , test "geting props" <|
                \_ ->
                    case decodeString Tiled.decode Mock.bareMinimum of
                        Ok { properties } ->
                            Expect.notEqual properties Dict.empty

                        Err err ->
                            Expect.fail err
            ]
        , describe "Tiled.Decode.decodeTiles"
            [ test "Animations" <|
                \_ ->
                    decodeString Tiled.decodeTiles Mock.tilesDataOldAnimations
                        |> Expect.equal (decodeString Tiled.decodeTiles Mock.tilesDataNewAnimations)
            , test "Properties" <|
                \_ ->
                    decodeString Tiled.decodeTiles Mock.tilesDataOldWithProps
                        |> Expect.equal (decodeString Tiled.decodeTiles Mock.tilesDataNewWithProps)
            ]
        ]
