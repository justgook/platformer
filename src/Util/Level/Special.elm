module Util.Level.Special exposing (LevelProps, decode, init)

import Json.Decode exposing (field)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)
import Util.Level exposing (Layer(..), Level, LevelWith, Object(..), Tileset(..), decodeWith, defaultOptions, initWith)


levelCustomProperties : LevelProps
levelCustomProperties =
    { pixelPerUnit = 100
    , gravity = -10
    }


decode : Json.Decode.Decoder (LevelWith LevelProps Layer Tileset)
decode =
    decodeWith
        { defaultOptions
            | properties = levelPropsDecode
            , defaultCustomProperties = levelCustomProperties
            , tileset = tilesetDecoder
        }


init : LevelWith LevelProps Layer Tileset
init =
    initWith levelCustomProperties


tilesetDecoder : Json.Decode.Decoder Tileset
tilesetDecoder =
    defaultOptions.tileset
        |> Json.Decode.andThen
            (\data -> Json.Decode.succeed data)


levelPropsDecode : LevelProps -> Json.Decode.Decoder LevelProps
levelPropsDecode { pixelPerUnit, gravity } =
    Json.Decode.Pipeline.decode LevelProps
        |> optional "pixelPerUnit" Json.Decode.float pixelPerUnit
        |> optional "gravity" Json.Decode.float gravity


type alias LevelProps =
    { pixelPerUnit : Float
    , gravity : Float
    }
