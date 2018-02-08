module Game.Level exposing (..)

import Json.Decode exposing (field)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)
import Json.Encode


-- https://robots.thoughtbot.com/5-common-json-decoders#5---conditional-decoding-based-on-a-field
-- http://eeue56.github.io/json-to-elm/


type alias Level =
    { height : Int
    , infinite : Bool
    , layers : List Layer
    , nextobjectid : Int
    , orientation : String
    , renderorder : String
    , tiledversion : String
    , tileheight : Int
    , tilesets : List Tilesets
    , tilewidth : Int
    , kind : String
    , version : Int
    , width : Int
    }


model : Level
model =
    { height = 0
    , infinite = False
    , layers = []
    , nextobjectid = 0
    , orientation = ""
    , renderorder = ""
    , tiledversion = ""
    , tileheight = 0
    , tilesets = []
    , tilewidth = 0
    , kind = ""
    , version = 0
    , width = 0
    }


decodeLevel : Json.Decode.Decoder Level
decodeLevel =
    Json.Decode.Pipeline.decode Level
        |> Json.Decode.Pipeline.required "height" Json.Decode.int
        |> Json.Decode.Pipeline.required "infinite" Json.Decode.bool
        |> Json.Decode.Pipeline.required "layers" (Json.Decode.list decodeLayer)
        |> Json.Decode.Pipeline.required "nextobjectid" Json.Decode.int
        |> Json.Decode.Pipeline.required "orientation" Json.Decode.string
        |> Json.Decode.Pipeline.required "renderorder" Json.Decode.string
        |> Json.Decode.Pipeline.required "tiledversion" Json.Decode.string
        |> Json.Decode.Pipeline.required "tileheight" Json.Decode.int
        |> Json.Decode.Pipeline.required "tilesets" (Json.Decode.list decodeTilesets)
        |> Json.Decode.Pipeline.required "tilewidth" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "version" Json.Decode.int
        |> Json.Decode.Pipeline.required "width" Json.Decode.int


encodeLevel : Level -> Json.Encode.Value
encodeLevel record =
    Json.Encode.object
        [ ( "height", Json.Encode.int <| record.height )
        , ( "infinite", Json.Encode.bool <| record.infinite )
        , ( "layers", Json.Encode.list <| List.map encodeLayer <| record.layers )
        , ( "nextobjectid", Json.Encode.int <| record.nextobjectid )
        , ( "orientation", Json.Encode.string <| record.orientation )
        , ( "renderorder", Json.Encode.string <| record.renderorder )
        , ( "tiledversion", Json.Encode.string <| record.tiledversion )
        , ( "tileheight", Json.Encode.int <| record.tileheight )
        , ( "tilesets", Json.Encode.list <| List.map encodeTilesets <| record.tilesets )
        , ( "tilewidth", Json.Encode.int <| record.tilewidth )
        , ( "type", Json.Encode.string <| record.kind )
        , ( "version", Json.Encode.int <| record.version )
        , ( "width", Json.Encode.int <| record.width )
        ]


type alias Tilesets =
    { firstgid : Int
    , source : String
    }


decodeTilesets : Json.Decode.Decoder Tilesets
decodeTilesets =
    Json.Decode.map2 Tilesets
        (field "firstgid" Json.Decode.int)
        (field "source" Json.Decode.string)


encodeTilesets : Tilesets -> Json.Encode.Value
encodeTilesets record =
    Json.Encode.object
        [ ( "firstgid", Json.Encode.int <| record.firstgid )
        , ( "source", Json.Encode.string <| record.source )
        ]


type Layer
    = Image ImageLayer
    | Tile TileLayer


decodeLayer : Json.Decode.Decoder Layer
decodeLayer =
    field "type" Json.Decode.string
        |> Json.Decode.andThen layerFromType


encodeLayer : Layer -> Json.Encode.Value
encodeLayer record =
    case record of
        Image data ->
            encodeImageLayer data

        Tile data ->
            encodeTileLayer data


layerFromType : String -> Json.Decode.Decoder Layer
layerFromType string =
    case string of
        "tilelayer" ->
            Json.Decode.map Tile decodeTileLayer

        "imagelayer" ->
            Json.Decode.map Image decodeImageLayer

        _ ->
            Json.Decode.fail ("Invalid layer type: " ++ string)


type alias ImageLayer =
    { image : String
    , name : String
    , opacity : Int
    , kind : String
    , visible : Bool
    , x : Int
    , y : Int
    }


decodeImageLayer : Json.Decode.Decoder ImageLayer
decodeImageLayer =
    Json.Decode.Pipeline.decode ImageLayer
        |> Json.Decode.Pipeline.required "image" Json.Decode.string
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "opacity" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int


encodeImageLayer : ImageLayer -> Json.Encode.Value
encodeImageLayer record =
    Json.Encode.object
        [ ( "image", Json.Encode.string <| record.image )
        , ( "name", Json.Encode.string <| record.name )
        , ( "opacity", Json.Encode.int <| record.opacity )
        , ( "type", Json.Encode.string <| record.kind )
        , ( "visible", Json.Encode.bool <| record.visible )
        , ( "x", Json.Encode.int <| record.x )
        , ( "y", Json.Encode.int <| record.y )
        ]


type alias TileLayer =
    { data : String
    , encoding : String
    , height : Int
    , name : String
    , opacity : Int
    , kind : String
    , visible : Bool
    , width : Int
    , x : Int
    , y : Int
    }


decodeTileLayer : Json.Decode.Decoder TileLayer
decodeTileLayer =
    Json.Decode.Pipeline.decode TileLayer
        |> Json.Decode.Pipeline.required "data" Json.Decode.string
        |> Json.Decode.Pipeline.required "encoding" Json.Decode.string
        |> Json.Decode.Pipeline.required "height" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "opacity" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "width" Json.Decode.int
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int


encodeTileLayer : TileLayer -> Json.Encode.Value
encodeTileLayer record =
    Json.Encode.object
        [ ( "data", Json.Encode.string <| record.data )
        , ( "encoding", Json.Encode.string <| record.encoding )
        , ( "height", Json.Encode.int <| record.height )
        , ( "name", Json.Encode.string <| record.name )
        , ( "opacity", Json.Encode.int <| record.opacity )
        , ( "type", Json.Encode.string <| record.kind )
        , ( "visible", Json.Encode.bool <| record.visible )
        , ( "width", Json.Encode.int <| record.width )
        , ( "x", Json.Encode.int <| record.x )
        , ( "y", Json.Encode.int <| record.y )
        ]
