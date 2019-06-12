module RangeTree exposing (suite)

import Array
import Dict
import Expect exposing (Expectation)
import Fuzz
import Logic.Template.Internal.RangeTree as RangeTree
import Test exposing (..)


suite : Test
suite =
    describe "Functionality"
        [ fuzz2 fuzzItem fuzzList "List manipulation" <|
            \item list ->
                let
                    ( a, b ) =
                        item

                    fromList =
                        RangeTree.fromList a b list

                    toList =
                        RangeTree.toList fromList
                in
                Expect.equal (List.sort toList) (List.sort (item :: list))
        , fuzz2 fuzzItemArray Fuzz.int "Get" <|
            \( item, array ) i ->
                let
                    ( a, b ) =
                        item

                    length =
                        Array.length array + 1

                    index =
                        modBy length (abs i + 1)

                    ( id, value ) =
                        Array.get (index - 1) array
                            |> Maybe.withDefault item

                    list =
                        Array.toList array

                    fromList =
                        RangeTree.fromList a b list
                in
                Expect.equal (RangeTree.get id fromList) value
        ]


fuzzItem =
    Fuzz.tuple ( Fuzz.int, Fuzz.int )


fuzzList =
    Fuzz.list fuzzItem


fuzzItemArray =
    Fuzz.map2
        (\i l ->
            case l of
                item :: rest ->
                    ( item, Array.fromList rest )

                [] ->
                    ( i, Array.empty )
        )
        fuzzItem
        (Fuzz.list fuzzItem |> Fuzz.map (Dict.fromList >> Dict.toList))
