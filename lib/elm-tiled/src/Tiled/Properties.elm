module Tiled.Properties exposing
    ( Properties, Property(..)
    , decode, encode
    )

{-|

@docs Properties, Property
@docs decode, encode

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, bool, dict, fail, float, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


{-| -}
type alias Properties =
    Dict String Property


{-| Custom properties values
-}
type Property
    = PropBool Bool
    | PropInt Int
    | PropFloat Float
    | PropString String
    | PropColor String
    | PropFile String


{-| -}
decode : Decoder Properties
decode =
    Decode.list
        (Decode.succeed identity
            |> required "type" Decode.string
            |> Decode.andThen
                (\kind ->
                    Decode.succeed (\a b -> ( a, b ))
                        |> required "name" Decode.string
                        |> required "value" (decodeProperty kind)
                )
        )
        |> Decode.map Dict.fromList


{-| -}
encode : Properties -> Encode.Value
encode props =
    props
        |> Dict.toList
        |> Encode.list
            (\( key, value ) ->
                Encode.object
                    ([ ( "name", Encode.string key )
                     ]
                        ++ (case value of
                                PropBool v ->
                                    [ ( "type", Encode.string "bool" ), ( "value", Encode.bool v ) ]

                                PropInt v ->
                                    [ ( "type", Encode.string "int" ), ( "value", Encode.int v ) ]

                                PropFloat v ->
                                    [ ( "type", Encode.string "float" ), ( "value", Encode.float v ) ]

                                PropString v ->
                                    [ ( "type", Encode.string "string" ), ( "value", Encode.string v ) ]

                                PropColor v ->
                                    [ ( "type", Encode.string "color" ), ( "value", Encode.string v ) ]

                                PropFile v ->
                                    [ ( "type", Encode.string "file" ), ( "value", Encode.string v ) ]
                           )
                    )
            )


{-| -}
decodeProperty : String -> Decoder Property
decodeProperty typeString =
    case typeString of
        "bool" ->
            Decode.map PropBool Decode.bool

        "color" ->
            Decode.map PropColor Decode.string

        "float" ->
            Decode.map PropFloat Decode.float

        "file" ->
            Decode.map PropFile Decode.string

        "int" ->
            Decode.map PropInt Decode.int

        "string" ->
            Decode.map PropString Decode.string

        _ ->
            Decode.fail <| "I can't decode the type " ++ typeString
