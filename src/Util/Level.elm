module Util.Level exposing (Layer(..), Level, Object(..), Tileset(..), decode, decodeWith, init)

import BinaryBase64
import Bitwise exposing (or, shiftLeftBy)
import Json.Decode exposing (field)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)


-- https://robots.thoughtbot.com/5-common-json-decoders#5---conditional-decoding-based-on-a-field
-- http://eeue56.github.io/json-to-elm/


type alias Level =
    LevelWith Layer Tileset


type alias LevelWith layer tileset =
    { height : Int
    , infinite : Bool
    , layers : List layer
    , nextobjectid : Int
    , orientation : String
    , renderorder : String
    , tiledversion : String
    , tileheight : Float
    , tilesets : List tileset
    , tilewidth : Float
    , kind : String
    , version : Int
    , width : Int
    }


init : Level
init =
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


decodeWith : { b | layer : Json.Decode.Decoder a, tileset : Json.Decode.Decoder a1 } -> Json.Decode.Decoder (LevelWith a a1)
decodeWith { layer, tileset } =
    Json.Decode.Pipeline.decode LevelWith
        |> Json.Decode.Pipeline.required "height" Json.Decode.int
        |> Json.Decode.Pipeline.required "infinite" Json.Decode.bool
        |> Json.Decode.Pipeline.required "layers" (Json.Decode.list layer)
        |> Json.Decode.Pipeline.required "nextobjectid" Json.Decode.int
        |> Json.Decode.Pipeline.required "orientation" Json.Decode.string
        |> Json.Decode.Pipeline.required "renderorder" Json.Decode.string
        |> Json.Decode.Pipeline.required "tiledversion" Json.Decode.string
        |> Json.Decode.Pipeline.required "tileheight" Json.Decode.float
        |> Json.Decode.Pipeline.required "tilesets" (Json.Decode.list tileset)
        |> Json.Decode.Pipeline.required "tilewidth" Json.Decode.float
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "version" Json.Decode.int
        |> Json.Decode.Pipeline.required "width" Json.Decode.int


defaultOptions : { layer : Json.Decode.Decoder Layer, tileset : Json.Decode.Decoder Tileset }
defaultOptions =
    { layer = decodeLayer, tileset = decodeTileset }


decode : Json.Decode.Decoder Level
decode =
    decodeWith defaultOptions


type Tileset
    = TilesetSource SourceTileData
    | TilesetEmbedded EmbeddedTileData


decodeTileset : Json.Decode.Decoder Tileset
decodeTileset =
    Json.Decode.oneOf [ decodeEmbeddedTileset, decodeSourceTileset ]


type alias SourceTileData =
    { firstgid : Int
    , source : String
    }


decodeSourceTileset : Json.Decode.Decoder Tileset
decodeSourceTileset =
    Json.Decode.Pipeline.decode SourceTileData
        |> Json.Decode.Pipeline.required "firstgid" Json.Decode.int
        |> Json.Decode.Pipeline.required "source" Json.Decode.string
        |> Json.Decode.map TilesetSource


type alias EmbeddedTileData =
    { columns : Int
    , firstgid : Int
    , image : String
    , imageheight : Int
    , imagewidth : Int
    , margin : Int
    , name : String
    , spacing : Int
    , tilecount : Int
    , tileheight : Int
    , tilewidth : Int
    , transparentcolor : String
    }


decodeEmbeddedTileset : Json.Decode.Decoder Tileset
decodeEmbeddedTileset =
    Json.Decode.Pipeline.decode EmbeddedTileData
        |> Json.Decode.Pipeline.required "columns" Json.Decode.int
        |> Json.Decode.Pipeline.required "firstgid" Json.Decode.int
        |> Json.Decode.Pipeline.required "image" Json.Decode.string
        |> Json.Decode.Pipeline.required "imageheight" Json.Decode.int
        |> Json.Decode.Pipeline.required "imagewidth" Json.Decode.int
        |> Json.Decode.Pipeline.required "margin" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "spacing" Json.Decode.int
        |> Json.Decode.Pipeline.required "tilecount" Json.Decode.int
        |> Json.Decode.Pipeline.required "tileheight" Json.Decode.int
        |> Json.Decode.Pipeline.required "tilewidth" Json.Decode.int
        |> Json.Decode.Pipeline.required "transparentcolor" Json.Decode.string
        |> Json.Decode.map TilesetEmbedded


type Layer
    = ImageLayer ImageLayerData
    | TileLayer TileLayerData
    | ObjectLayer ObjectLayerData


decodeLayer : Json.Decode.Decoder Layer
decodeLayer =
    field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\string ->
                case string of
                    "tilelayer" ->
                        Json.Decode.map TileLayer decodeTileLayer

                    "imagelayer" ->
                        Json.Decode.map ImageLayer decodeImageLayer

                    "objectgroup" ->
                        Json.Decode.map ObjectLayer decodeObjectLayer

                    _ ->
                        Json.Decode.fail ("Invalid layer type: " ++ string)
            )


type alias ImageLayerData =
    { image : String
    , name : String
    , opacity : Float
    , kind : String
    , visible : Bool
    , x : Int
    , y : Int
    }


decodeImageLayer : Json.Decode.Decoder ImageLayerData
decodeImageLayer =
    Json.Decode.Pipeline.decode ImageLayerData
        |> Json.Decode.Pipeline.required "image" Json.Decode.string
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "opacity" Json.Decode.float
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int


type alias TileLayerData =
    { data : List Int
    , height : Int
    , name : String
    , opacity : Float
    , kind : String
    , visible : Bool
    , width : Int
    , x : Int
    , y : Int
    }


decodeTileLayer : Json.Decode.Decoder TileLayerData
decodeTileLayer =
    Json.Decode.Pipeline.decode (,)
        |> Json.Decode.Pipeline.required "encoding" Json.Decode.string
        |> Json.Decode.Pipeline.optional "compression" Json.Decode.string "none"
        |> Json.Decode.andThen
            (\( encoding, compression ) ->
                Json.Decode.Pipeline.decode TileLayerData
                    |> Json.Decode.Pipeline.required "data" (decodeTileLayerData encoding compression)
                    |> Json.Decode.Pipeline.required "height" Json.Decode.int
                    |> Json.Decode.Pipeline.required "name" Json.Decode.string
                    |> Json.Decode.Pipeline.required "opacity" Json.Decode.float
                    |> Json.Decode.Pipeline.required "type" Json.Decode.string
                    |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
                    |> Json.Decode.Pipeline.required "width" Json.Decode.int
                    |> Json.Decode.Pipeline.required "x" Json.Decode.int
                    |> Json.Decode.Pipeline.required "y" Json.Decode.int
            )


decodeTileLayerData : String -> String -> Json.Decode.Decoder (List Int)
decodeTileLayerData encoding compression =
    if compression /= "none" then
        Json.Decode.fail "Tile layer compression not supported yet"
    else if encoding == "base64" then
        Json.Decode.string
            |> Json.Decode.andThen
                (\string ->
                    string
                        |> BinaryBase64.decode
                        |> Result.map (\data -> Json.Decode.succeed (convertTilesData data))
                        |> resultExtract (\err -> Json.Decode.fail err)
                )
    else
        Json.Decode.list Json.Decode.int


shiftValues : List Int
shiftValues =
    [ 0, 8, 16, 24 ]


convertTilesData : BinaryBase64.ByteString -> List Int
convertTilesData octets =
    let
        ( dword, rest ) =
            ( List.take 4 octets, List.drop 4 octets )

        value =
            zip shiftValues dword
                |> List.foldl
                    (\( shiftValues, octet ) acc ->
                        or (octet |> shiftLeftBy shiftValues) acc
                    )
                    0
    in
    if List.isEmpty rest then
        [ value ]
    else
        value :: convertTilesData rest


zip : List a -> List b -> List ( a, b )
zip =
    List.map2 (,)



-- http://package.elm-lang.org/packages/elm-community/result-extra/2.2.0/Result-Extra


resultExtract : (e -> a) -> Result e a -> a
resultExtract f x =
    case x of
        Ok a ->
            a

        Err e ->
            f e



------------------------------------------------------------------------------------------


type alias ObjectLayerData =
    { draworder : String
    , name : String
    , objects : List Object
    , opacity : Float
    , kind : String
    , visible : Bool
    , x : Int
    , y : Int
    }


decodeObjectLayer : Json.Decode.Decoder ObjectLayerData
decodeObjectLayer =
    Json.Decode.Pipeline.decode ObjectLayerData
        |> Json.Decode.Pipeline.required "draworder" Json.Decode.string
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "objects" (Json.Decode.list decodeObject)
        |> Json.Decode.Pipeline.required "opacity" Json.Decode.float
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int


type Object
    = ObjectPoint ObjectPointData
    | ObjectRectangle ObjectRectangleData
    | ObjectEllipse ObjectRectangleData
    | ObjectPolygon ObjectPolygonData


decodeObject : Json.Decode.Decoder Object
decodeObject =
    -- maybe use Json.Decode.Pipeline.resolve
    Json.Decode.Pipeline.decode (,,)
        |> Json.Decode.Pipeline.optional "point" Json.Decode.bool False
        |> Json.Decode.Pipeline.optional "ellipse" Json.Decode.bool False
        |> Json.Decode.Pipeline.optional "polygon" (Json.Decode.list decodeObjectPolygonPoint) []
        |> Json.Decode.andThen
            (\( point, ellipse, polygon ) ->
                case ( point, ellipse, polygon ) of
                    ( False, False, [] ) ->
                        Json.Decode.map ObjectRectangle decodeObjectRectangle

                    ( True, _, [] ) ->
                        Json.Decode.map ObjectPoint decodeObjectPoint

                    ( _, True, [] ) ->
                        Json.Decode.map ObjectEllipse decodeObjectRectangle

                    ( _, _, list ) ->
                        Json.Decode.map ObjectPolygon decodeObjectPolygonData
            )


type alias ObjectPolygonData =
    { height : Int
    , id : Int
    , name : String
    , polygon : List ObjectPolygonPoint
    , rotation : Int
    , kind : String
    , visible : Bool
    , width : Int
    , x : Float
    , y : Float
    }


type alias ObjectPolygonPoint =
    { x : Float
    , y : Float
    }


decodeObjectPolygonPoint : Json.Decode.Decoder ObjectPolygonPoint
decodeObjectPolygonPoint =
    Json.Decode.map2 ObjectPolygonPoint
        (field "x" Json.Decode.float)
        (field "y" Json.Decode.float)


decodeObjectPolygonData : Json.Decode.Decoder ObjectPolygonData
decodeObjectPolygonData =
    Json.Decode.Pipeline.decode ObjectPolygonData
        |> Json.Decode.Pipeline.required "height" Json.Decode.int
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "polygon" (Json.Decode.list decodeObjectPolygonPoint)
        |> Json.Decode.Pipeline.required "rotation" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "width" Json.Decode.int
        |> Json.Decode.Pipeline.required "x" Json.Decode.float
        |> Json.Decode.Pipeline.required "y" Json.Decode.float


type alias ObjectRectangleData =
    { height : Float
    , id : Int
    , name : String
    , rotation : Int
    , kind : String
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    }


decodeObjectRectangle : Json.Decode.Decoder ObjectRectangleData
decodeObjectRectangle =
    Json.Decode.Pipeline.decode ObjectRectangleData
        |> Json.Decode.Pipeline.required "height" Json.Decode.float
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "rotation" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "width" Json.Decode.float
        |> Json.Decode.Pipeline.required "x" Json.Decode.float
        |> Json.Decode.Pipeline.required "y" Json.Decode.float


type alias ObjectPointData =
    { id : Int
    , name : String
    , rotation : Int
    , kind : String
    , visible : Bool
    , x : Float
    , y : Float
    }


decodeObjectPoint : Json.Decode.Decoder ObjectPointData
decodeObjectPoint =
    Json.Decode.Pipeline.decode ObjectPointData
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "rotation" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "x" Json.Decode.float
        |> Json.Decode.Pipeline.required "y" Json.Decode.float
