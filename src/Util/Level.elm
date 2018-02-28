module Util.Level exposing (Layer(..), Level, LevelWith, Object(..), Tileset(..), decode, decodeWith, defaultOptions, init, initWith)

import BinaryBase64
import Bitwise exposing (or, shiftLeftBy)
import Dict exposing (Dict)
import Json.Decode exposing (field)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)


-- https://robots.thoughtbot.com/5-common-json-decoders#5---conditional-decoding-based-on-a-field
-- http://eeue56.github.io/json-to-elm/


type alias Level =
    LevelWith {} Layer Tileset


type alias LevelWith customProperties layer tileset =
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
    , version : Float
    , width : Int
    , properties : customProperties
    }


init : Level
init =
    initWith {}


initWith : props -> LevelWith props layer tileset
initWith props =
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
    , properties = props
    }


decodeWith : { c | defaultCustomProperties : b, layer : Json.Decode.Decoder a, properties : b -> Json.Decode.Decoder b, tileset : Json.Decode.Decoder a1 } -> Json.Decode.Decoder (LevelWith b a a1)
decodeWith { layer, tileset, properties, defaultCustomProperties } =
    Json.Decode.Pipeline.decode LevelWith
        |> required "height" Json.Decode.int
        |> required "infinite" Json.Decode.bool
        |> required "layers" (Json.Decode.list layer)
        |> required "nextobjectid" Json.Decode.int
        |> required "orientation" Json.Decode.string
        |> required "renderorder" Json.Decode.string
        |> required "tiledversion" Json.Decode.string
        |> required "tileheight" Json.Decode.float
        |> required "tilesets" (Json.Decode.list tileset)
        |> required "tilewidth" Json.Decode.float
        |> required "type" Json.Decode.string
        |> required "version" Json.Decode.float
        |> required "width" Json.Decode.int
        |> optional "properties" (properties defaultCustomProperties) defaultCustomProperties


defaultOptions : { defaultCustomProperties : {}, layer : Json.Decode.Decoder Layer, properties : a -> Json.Decode.Decoder {}, tileset : Json.Decode.Decoder Tileset }
defaultOptions =
    { layer = decodeLayer
    , tileset = decodeTileset
    , properties = \_ -> Json.Decode.succeed {}
    , defaultCustomProperties = {}
    }


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
        |> required "firstgid" Json.Decode.int
        |> required "source" Json.Decode.string
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
    , tiles : Dict Int TilesData
    }


decodeEmbeddedTileset : Json.Decode.Decoder Tileset
decodeEmbeddedTileset =
    Json.Decode.Pipeline.decode EmbeddedTileData
        |> required "columns" Json.Decode.int
        |> required "firstgid" Json.Decode.int
        |> required "image" Json.Decode.string
        |> required "imageheight" Json.Decode.int
        |> required "imagewidth" Json.Decode.int
        |> required "margin" Json.Decode.int
        |> required "name" Json.Decode.string
        |> required "spacing" Json.Decode.int
        |> required "tilecount" Json.Decode.int
        |> required "tileheight" Json.Decode.int
        |> required "tilewidth" Json.Decode.int
        |> required "transparentcolor" Json.Decode.string
        |> optional "tiles" decodeTiles Dict.empty
        |> Json.Decode.map TilesetEmbedded


decodeTiles : Json.Decode.Decoder (Dict Int TilesData)
decodeTiles =
    let
        newFormat =
            Json.Decode.list decodeTilesDataNew
                |> Json.Decode.andThen
                    (List.foldl
                        (\data acc ->
                            acc |> Json.Decode.andThen (Dict.insert data.id { animation = data.animation, objectgroup = data.objectgroup } >> Json.Decode.succeed)
                        )
                        (Json.Decode.succeed Dict.empty)
                    )

        oldFormat =
            Json.Decode.keyValuePairs decodeTilesData
                |> Json.Decode.andThen
                    (List.foldl
                        (\( i, data ) acc ->
                            case String.toInt i of
                                Ok index ->
                                    acc |> Json.Decode.andThen (Dict.insert index data >> Json.Decode.succeed)

                                Err a ->
                                    Json.Decode.fail a
                        )
                        (Json.Decode.succeed Dict.empty)
                    )
    in
    Json.Decode.oneOf [ oldFormat, newFormat ]


type alias TilesData =
    TilesDataPlain {}


type alias TilesDataPlain a =
    { a
        | animation : Maybe (List SpriteAnimation)
        , objectgroup : Maybe TilesDataObjectgroup
    }


type alias TilesDataObjectgroup =
    { draworder : String
    , name : String
    , objects : List Object
    , opacity : Int
    , kind : String
    , visible : Bool
    , x : Int
    , y : Int
    }


decodeTilesData : Json.Decode.Decoder TilesData
decodeTilesData =
    Json.Decode.map2 (\a b -> { animation = a, objectgroup = b })
        (Json.Decode.maybe (field "animation" (Json.Decode.list decodeSpriteAnimation)))
        (Json.Decode.maybe (field "objectgroup" decodeTilesDataObjectgroup))


decodeTilesDataNew : Json.Decode.Decoder (TilesDataPlain { id : Int })
decodeTilesDataNew =
    Json.Decode.map3 (\a b c -> { animation = a, objectgroup = b, id = c })
        (Json.Decode.maybe (field "animation" (Json.Decode.list decodeSpriteAnimation)))
        (Json.Decode.maybe (field "objectgroup" decodeTilesDataObjectgroup))
        (field "id" Json.Decode.int)


decodeTilesDataObjectgroup : Json.Decode.Decoder TilesDataObjectgroup
decodeTilesDataObjectgroup =
    Json.Decode.Pipeline.decode TilesDataObjectgroup
        |> Json.Decode.Pipeline.required "draworder" Json.Decode.string
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "objects" (Json.Decode.list decodeObject)
        |> Json.Decode.Pipeline.required "opacity" Json.Decode.int
        |> Json.Decode.Pipeline.required "type" Json.Decode.string
        |> Json.Decode.Pipeline.required "visible" Json.Decode.bool
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int


type alias SpriteAnimation =
    { duration : Int
    , tileid : Int
    }


decodeSpriteAnimation : Json.Decode.Decoder SpriteAnimation
decodeSpriteAnimation =
    Json.Decode.map2 SpriteAnimation
        (field "duration" Json.Decode.int)
        (field "tileid" Json.Decode.int)


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
    , x : Float
    , y : Float
    }


decodeImageLayer : Json.Decode.Decoder ImageLayerData
decodeImageLayer =
    Json.Decode.Pipeline.decode ImageLayerData
        |> required "image" Json.Decode.string
        |> required "name" Json.Decode.string
        |> required "opacity" Json.Decode.float
        |> required "type" Json.Decode.string
        |> required "visible" Json.Decode.bool
        |> required "x" Json.Decode.float
        |> required "y" Json.Decode.float


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
        |> optional "encoding" Json.Decode.string "none"
        |> optional "compression" Json.Decode.string "none"
        |> Json.Decode.andThen
            (\( encoding, compression ) ->
                Json.Decode.Pipeline.decode TileLayerData
                    |> required "data" (decodeTileLayerData encoding compression)
                    |> required "height" Json.Decode.int
                    |> required "name" Json.Decode.string
                    |> required "opacity" Json.Decode.float
                    |> required "type" Json.Decode.string
                    |> required "visible" Json.Decode.bool
                    |> required "width" Json.Decode.int
                    |> required "x" Json.Decode.int
                    |> required "y" Json.Decode.int
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
        |> required "draworder" Json.Decode.string
        |> required "name" Json.Decode.string
        |> required "objects" (Json.Decode.list decodeObject)
        |> required "opacity" Json.Decode.float
        |> required "type" Json.Decode.string
        |> required "visible" Json.Decode.bool
        |> required "x" Json.Decode.int
        |> required "y" Json.Decode.int


type Object
    = ObjectPoint ObjectPointData
    | ObjectRectangle ObjectRectangleData
    | ObjectEllipse ObjectRectangleData
    | ObjectPolygon ObjectPolygonData


decodeObject : Json.Decode.Decoder Object
decodeObject =
    -- maybe use Json.Decode.Pipeline.resolve
    Json.Decode.Pipeline.decode (,,)
        |> optional "point" Json.Decode.bool False
        |> optional "ellipse" Json.Decode.bool False
        |> optional "polygon" (Json.Decode.list decodeObjectPolygonPoint) []
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
        |> required "height" Json.Decode.int
        |> required "id" Json.Decode.int
        |> required "name" Json.Decode.string
        |> required "polygon" (Json.Decode.list decodeObjectPolygonPoint)
        |> required "rotation" Json.Decode.int
        |> required "type" Json.Decode.string
        |> required "visible" Json.Decode.bool
        |> required "width" Json.Decode.int
        |> required "x" Json.Decode.float
        |> required "y" Json.Decode.float


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
        |> required "height" Json.Decode.float
        |> required "id" Json.Decode.int
        |> required "name" Json.Decode.string
        |> required "rotation" Json.Decode.int
        |> required "type" Json.Decode.string
        |> required "visible" Json.Decode.bool
        |> required "width" Json.Decode.float
        |> required "x" Json.Decode.float
        |> required "y" Json.Decode.float


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
        |> required "id" Json.Decode.int
        |> required "name" Json.Decode.string
        |> required "rotation" Json.Decode.int
        |> required "type" Json.Decode.string
        |> required "visible" Json.Decode.bool
        |> required "x" Json.Decode.float
        |> required "y" Json.Decode.float
