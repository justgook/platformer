module Tiled.Decode
    exposing
        ( CustomProperties
        , DrawOrder(..)
        , EmbeddedTileData
        , ImageCollectionTileData
        , ImageCollectionTileDataTile
        , ImageLayerData
        , Layer(..)
        , Level
        , Object(..)
        , ObjectLayerData
        , ObjectPointData
        , ObjectPolyPoint
        , ObjectPolygonData
        , ObjectRectangleData
        , ObjectTileData
        , Orientation(..)
        , Property(..)
        , RenderOrder(..)
        , SourceTileData
        , TileLayerData
        , Tileset(..)
        , decode
        , empty
        , decodeTileset
        , decodeTiles
        , TilesData
        )

{-| Use the [`decode`](#decode) to get [`Level`](#Level)


# Default Decoding

@docs decode, empty

##Level

@docs Level, Orientation

##Layers

@docs Layer, ImageLayerData, TileLayerData, ObjectLayerData

##TileSets
@docs Tileset, SourceTileData, EmbeddedTileData, ImageCollectionTileData, ImageCollectionTileDataTile, TilesData

##Objects
Objects that is used inside [`ObjectLayerData`](#ObjectLayerData)
@docs Object, ObjectPointData, ObjectRectangleData, ObjectPolygonData, ObjectPolygonData, ObjectTileData, ObjectPolyPoint


# Properties

@docs CustomProperties, Property, RenderOrder, DrawOrder

##Sub-decoders

@docs decodeTileset, decodeTiles

-}

import BinaryBase64
import Bitwise exposing (or, shiftLeftBy)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)


-- https://robots.thoughtbot.com/5-common-json-decoders#5---conditional-decoding-based-on-a-field
-- http://eeue56.github.io/json-to-elm/


{-| -}
type alias CustomProperties =
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


{-|

  - `backgroundcolor` string Hex-formatted color (`#RRGGBB` or `#AARRGGBB`) (default `none`)
  - `width` Number of tile columns
  - `height` Number of tile rows
  - `tilewidth` Map grid width
  - `tileheight` Map grid height
  - `infinite` Whether the map has infinite dimensions
  - `orientation` orthogonal, isometric, staggered or hexagonal
  - `renderorder` Rendering direction (orthogonal maps only)
  - `layers` List of layers
  - `tilesets` List of tilesets
  - `properties` A list of properties (name, value, type).
  - `version` The JSON format version
  - `tiledversion` The Tiled version used to save the file
-}
type alias Level =
    { backgroundcolor : String
    , width : Int
    , height : Int
    , tilewidth : Int
    , tileheight : Int
    , infinite : Bool
    , orientation : Orientation
    , renderorder : RenderOrder
    , layers : List Layer
    , tilesets : List Tileset
    , properties : CustomProperties
    , version : Float
    , tiledversion : String
    }


{-| Creates empty [`Level`](#Level)
-}
empty : Level
empty =
    { backgroundcolor = ""
    , height = 0
    , infinite = False
    , layers = []
    , orientation = Orthogonal
    , renderorder = RightDown
    , tiledversion = ""
    , tileheight = 0
    , tilesets = []
    , tilewidth = 0
    , version = 0
    , width = 0
    , properties = Dict.empty
    }


{-| Decodes [Tiled](http://www.mapeditor.org/) map (json encoded) to [`Level`](#Level) data structures

    Http.get "path/to/map.json" Tiled.decode
        |> Http.send LevelLoaded

    update msg model =
        case msg of
            LevelLoaded (Ok level) ->
                ( level, Cmd.none )
            LevelLoaded (Err err) ->
                Debug.crash "Tiled Map fail to decode" err

or

    level =
        case decodeString Tiled.decode "JSON STRING OF MAP" of
            Ok data ->
                Debug.log "Tiled Map decoded" data

            Err err ->
                Debug.crash "Tiled Map fail to decode" err

-}
decode : Decoder Level
decode =
    Pipeline.decode Level
        |> optional "backgroundcolor" Decode.string "none"
        |> required "width" Decode.int
        |> required "height" Decode.int
        |> required "tilewidth" Decode.int
        |> required "tileheight" Decode.int
        |> required "infinite" Decode.bool
        |> required "orientation" decodeOrientation
        |> required "renderorder" decodeRenderOrder
        |> required "layers" (Decode.list decodeLayer)
        |> required "tilesets" (Decode.list decodeTileset)
        |> Pipeline.custom propertiesDecoder
        |> required "version" Decode.float
        |> required "tiledversion" Decode.string


{-| -}
type RenderOrder
    = RightDown
    | RightUp
    | LeftDown
    | LeftUp


decodeRenderOrder : Decoder RenderOrder
decodeRenderOrder =
    Decode.string
        |> Decode.andThen
            (\result ->
                case result of
                    "right-down" ->
                        Decode.succeed RightDown

                    "right-up" ->
                        Decode.succeed RightUp

                    "left-down" ->
                        Decode.succeed LeftDown

                    "left-up" ->
                        Decode.succeed LeftUp

                    _ ->
                        Decode.fail "Unknow render order"
            )


{-| -}
type DrawOrder
    = TopDown
    | Index


decodeDrawOrder : Decoder DrawOrder
decodeDrawOrder =
    Decode.string
        |> Decode.andThen
            (\result ->
                case result of
                    "topdown" ->
                        Decode.succeed TopDown

                    "index" ->
                        Decode.succeed Index

                    _ ->
                        Decode.fail "Unknow draw order"
            )


{-| -}
type Orientation
    = Orthogonal
    | Isometric
    | Staggered
    | Hexagonal


decodeOrientation : Decoder Orientation
decodeOrientation =
    Decode.string
        |> Decode.andThen
            (\result ->
                case result of
                    "orthogonal" ->
                        Decode.succeed Orthogonal

                    "isometric" ->
                        Decode.succeed Isometric

                    "staggered" ->
                        Decode.succeed Staggered

                    "hexagonal" ->
                        Decode.succeed Hexagonal

                    _ ->
                        Decode.fail "Unknow orientation"
            )


{-| Tiles in teleset
-}
decodeTiles : Decoder (Dict Int TilesData)
decodeTiles =
    let
        doNothing a b c =
            c

        mergeIfBoth f a b c =
            Dict.merge doNothing f doNothing a b c

        oldPropsDecode tileproperties tilepropertytypes =
            mergeIfBoth
                (\i v1 v2 acc ->
                    case String.toInt i of
                        Ok index ->
                            acc
                                |> Decode.andThen
                                    (\aAAAA ->
                                        mergeIfBoth
                                            (\a b c ->
                                                Decode.andThen
                                                    (\d ->
                                                        case Decode.decodeValue (propertyDecoder c) b of
                                                            Ok resulValue ->
                                                                d |> Dict.insert a resulValue >> Decode.succeed

                                                            Err err ->
                                                                Decode.fail err
                                                    )
                                            )
                                            v1
                                            v2
                                            (Decode.succeed Dict.empty)
                                            |> Decode.andThen
                                                (\asd ->
                                                    Dict.insert index asd aAAAA |> Decode.succeed
                                                )
                                    )

                        Err a ->
                            Decode.fail a
                )
                tileproperties
                tilepropertytypes
                (Decode.succeed Dict.empty)

        oldTilesDecoder =
            Decode.map2 (\a b -> { animation = a, objectgroup = b })
                (Decode.maybe (field "animation" (Decode.list decodeSpriteAnimation)))
                (Decode.maybe (field "objectgroup" decodeTilesDataObjectgroup))
                |> Decode.keyValuePairs
                |> Decode.andThen
                    (List.foldl
                        (\( k, v ) acc ->
                            case String.toInt k of
                                Ok index ->
                                    acc |> Decode.andThen (Dict.insert index v >> Decode.succeed)

                                Err err ->
                                    Decode.fail err
                        )
                        (Decode.succeed Dict.empty)
                    )

        appendOldTileDataToProps tiles =
            Decode.map
                (\props ->
                    Dict.merge
                        (\k { objectgroup, animation } acc ->
                            Dict.insert k { objectgroup = objectgroup, animation = animation, properties = Dict.empty } acc
                        )
                        (\k { objectgroup, animation } properties acc ->
                            Dict.insert k { objectgroup = objectgroup, animation = animation, properties = properties } acc
                        )
                        (\k v2 acc -> Dict.insert k { objectgroup = Nothing, animation = Nothing, properties = Dict.empty } acc)
                        tiles
                        props
                        Dict.empty
                )

        old =
            Decode.map3
                (\tileproperties tilepropertytypes tiles ->
                    case ( tileproperties, tilepropertytypes ) of
                        ( Just prop, Just types ) ->
                            oldPropsDecode prop types
                                |> appendOldTileDataToProps tiles

                        _ ->
                            Dict.empty |> Decode.succeed |> appendOldTileDataToProps tiles
                )
                (Decode.field "tileproperties" (Decode.dict (Decode.dict Decode.value)) |> Decode.maybe)
                (Decode.field "tilepropertytypes" (Decode.dict (Decode.dict Decode.string)) |> Decode.maybe)
                (Decode.field "tiles" oldTilesDecoder)
                |> Decode.andThen identity

        new =
            Decode.list decodeTilesDataNew
                |> Decode.andThen
                    (List.foldl
                        (\{ id, objectgroup, animation, properties } acc ->
                            acc |> Decode.andThen (Dict.insert id { objectgroup = objectgroup, animation = animation, properties = properties } >> Decode.succeed)
                        )
                        (Decode.succeed Dict.empty)
                    )
                |> Decode.field "tiles"
    in
        Decode.oneOf [ new, old ]
            |> Decode.maybe
            |> Decode.map (Maybe.withDefault Dict.empty)


{-| -}
propertyDecoder : String -> Decoder Property
propertyDecoder typeString =
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


{-| Decoding properties (with predefined field names) as Dict String Poperty
-}
propertiesDecoderWith_Old : ( String, String ) -> Decoder (Dict String Property)
propertiesDecoderWith_Old ( properties, propertytypes ) =
    let
        combine : List (Decoder a) -> Decoder (List a)
        combine =
            List.foldr (Decode.map2 (::)) (Decode.succeed [])

        decodeProperty : ( String, String ) -> Decoder ( String, Property )
        decodeProperty ( propName, propType ) =
            Decode.at [ properties, propName ]
                (propertyDecoder propType)
                |> Decode.map ((,) propName)

        propertiesDecoder : Decoder (Dict String Property)
        propertiesDecoder =
            Decode.field propertytypes (Decode.keyValuePairs Decode.string)
                |> Decode.map (List.map decodeProperty)
                |> Decode.andThen combine
                |> Decode.map Dict.fromList
    in
        propertiesDecoder


propertiesDecoder_New : Decoder (Dict String Property)
propertiesDecoder_New =
    Decode.field "properties"
        (Decode.list
            (Pipeline.decode identity
                |> required "type" Decode.string
                |> Decode.andThen
                    (\kind ->
                        Pipeline.decode (,)
                            |> required "name" Decode.string
                            |> required "value" (propertyDecoder kind)
                    )
            )
            |> Decode.map Dict.fromList
        )


propertiesDecoderWith : ( String, String ) -> Decoder (Dict String Property)
propertiesDecoderWith ( properties, propertytypes ) =
    Decode.oneOf [ propertiesDecoder_New, propertiesDecoderWith_Old ( properties, propertytypes ) ]
        |> Decode.maybe
        |> Decode.map (Maybe.withDefault Dict.empty)


{-| Decoding properties as Dict String Poperty
-}
propertiesDecoder : Decoder CustomProperties
propertiesDecoder =
    propertiesDecoderWith ( "properties", "propertytypes" )


{-| -}
type Tileset
    = TilesetSource SourceTileData
    | TilesetEmbedded EmbeddedTileData
    | TilesetImageCollection ImageCollectionTileData


{-|

  - `columns` The number of tile columns in the tileset
  - `firstgid` GID corresponding to the first tile in the set
  - `margin` Buffer between image edge and first tile (pixels)
  - `name` Name given to this tileset
  - `spacing` Spacing between adjacent tiles in image (pixels)
  - `tilecount` The number of tiles in this tileset
  - `tileheight` Maximum height of tiles in this set
  - `tiles` Dict of [`ImageCollectionTileDataTile`](#ImageCollectionTileDataTile)
  - `tilewidth` Maximum width of tiles in this set
  - `properties` A list of properties (name, value, type).
-}
type alias ImageCollectionTileData =
    { columns : Int
    , firstgid : Int
    , margin : Int
    , name : String
    , spacing : Int
    , tilecount : Int
    , tileheight : Int
    , tiles : Dict Int ImageCollectionTileDataTile
    , tilewidth : Int
    , properties : CustomProperties
    }


{-| -}
type alias ImageCollectionTileDataTile =
    { image : String
    , imageheight : Int
    , imagewidth : Int
    }


{-| -}
decodeImageCollectionTileData : Decode.Decoder Tileset
decodeImageCollectionTileData =
    Pipeline.decode ImageCollectionTileData
        |> Pipeline.required "columns" Decode.int
        |> Pipeline.required "firstgid" Decode.int
        |> Pipeline.required "margin" Decode.int
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "spacing" Decode.int
        |> Pipeline.required "tilecount" Decode.int
        |> Pipeline.required "tileheight" Decode.int
        |> Pipeline.required "tiles" decodeImageCollectionTileDataTiles
        |> Pipeline.required "tilewidth" Decode.int
        |> Pipeline.custom propertiesDecoder
        |> Decode.map TilesetImageCollection


{-| -}
decodeImageCollectionTileDataTiles : Decoder (Dict Int ImageCollectionTileDataTile)
decodeImageCollectionTileDataTiles =
    Decode.keyValuePairs decodeImageCollectionTileDataTile
        |> Decode.andThen
            (List.foldl
                (\( i, data ) acc ->
                    case String.toInt i of
                        Ok index ->
                            acc |> Decode.andThen (Dict.insert index data >> Decode.succeed)

                        Err a ->
                            Decode.fail a
                )
                (Decode.succeed Dict.empty)
            )


{-| -}
decodeImageCollectionTileDataTile : Decode.Decoder ImageCollectionTileDataTile
decodeImageCollectionTileDataTile =
    Decode.map3 ImageCollectionTileDataTile
        (field "image" Decode.string)
        (field "imageheight" Decode.int)
        (field "imagewidth" Decode.int)


{-| -}
decodeTileset : Decoder Tileset
decodeTileset =
    Decode.oneOf [ decodeEmbeddedTileset, decodeSourceTileset, decodeImageCollectionTileData ]


{-| -}
type alias SourceTileData =
    { firstgid : Int
    , source : String
    }


{-| -}
decodeSourceTileset : Decoder Tileset
decodeSourceTileset =
    Pipeline.decode SourceTileData
        |> required "firstgid" Decode.int
        |> required "source" Decode.string
        |> Decode.map TilesetSource


{-|

  - `columns` The number of tile columns in the tileset
  - `firstgid` GID corresponding to the first tile in the set
  - `image` Image used for tiles in this set
  - `imagewidth` Width of source image in pixels
  - `imageheight` Height of source image in pixels
  - `margin` Buffer between image edge and first tile (pixels)
  - `name` Name given to this tileset
  - `spacing` Spacing between adjacent tiles in image (pixels)
  - `tilecount` The number of tiles in this tileset
  - `tileheight` Maximum height of tiles in this set
  - `tiles` Dict of TilesData [`TilesData`](#TilesData)
  - `tilewidth` Maximum width of tiles in this set
  - `properties` A list of properties (name, value, type).
-}
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
    , properties : CustomProperties
    }


{-| -}
decodeEmbeddedTileset : Decoder Tileset
decodeEmbeddedTileset =
    Pipeline.decode EmbeddedTileData
        |> required "columns" Decode.int
        |> required "firstgid" Decode.int
        |> required "image" Decode.string
        |> required "imageheight" Decode.int
        |> required "imagewidth" Decode.int
        |> required "margin" Decode.int
        |> required "name" Decode.string
        |> required "spacing" Decode.int
        |> required "tilecount" Decode.int
        |> required "tileheight" Decode.int
        |> required "tilewidth" Decode.int
        |> optional "transparentcolor" Decode.string "none"
        |> Pipeline.custom decodeTiles
        -- |> optional "tiles" decodeTiles Dict.empty
        |> Pipeline.custom propertiesDecoder
        |> Decode.map TilesetEmbedded


{-|

    - animation : Maybe (List SpriteAnimation)
    - objectgroup : Maybe TilesDataObjectgroup
    - properties : CustomProperties
-}
type alias TilesData =
    TilesDataPlain {}


{-| -}
type alias TilesDataPlain a =
    { a
        | animation : Maybe (List SpriteAnimation)
        , objectgroup : Maybe TilesDataObjectgroup
        , properties : CustomProperties
    }


{-| -}
type alias TilesDataObjectgroup =
    { draworder : DrawOrder
    , name : String
    , objects : List Object
    , opacity : Int
    , visible : Bool
    , x : Int
    , y : Int
    }


{-| -}
decodeTilesDataNew : Decoder (TilesDataPlain { id : Int })
decodeTilesDataNew =
    Decode.map4 (\a b c d -> { animation = a, objectgroup = b, properties = c, id = d })
        (Decode.maybe (field "animation" (Decode.list decodeSpriteAnimation)))
        (Decode.maybe (field "objectgroup" decodeTilesDataObjectgroup))
        (Decode.maybe propertiesDecoder_New |> Decode.map (Maybe.withDefault Dict.empty))
        (field "id" Decode.int)


{-| -}
decodeTilesDataObjectgroup : Decoder TilesDataObjectgroup
decodeTilesDataObjectgroup =
    Pipeline.decode TilesDataObjectgroup
        |> Pipeline.required "draworder" decodeDrawOrder
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "objects" (Decode.list decodeObject)
        |> Pipeline.required "opacity" Decode.int
        |> Pipeline.required "visible" Decode.bool
        |> Pipeline.required "x" Decode.int
        |> Pipeline.required "y" Decode.int


{-| -}
type alias SpriteAnimation =
    { duration : Int
    , tileid : Int
    }


{-| -}
decodeSpriteAnimation : Decoder SpriteAnimation
decodeSpriteAnimation =
    Decode.map2 SpriteAnimation
        (field "duration" Decode.int)
        (field "tileid" Decode.int)


{-| -}
type Layer
    = ImageLayer ImageLayerData
    | TileLayer TileLayerData
    | ObjectLayer ObjectLayerData


{-|

  - `image` - Image used as background
  - `name` Name assigned to this layer
  - `x` Horizontal layer offset in tiles. Always 0.
  - `y` Vertical layer offset in tiles. Always 0.
  - `opacity` Value between 0 and 1
  - `properties` A list of properties (name, value, type).
  - `visible` Whether layer is shown or hidden in editor
-}
type alias ImageLayerData =
    { image : String
    , name : String
    , opacity : Float
    , visible : Bool
    , x : Float
    , y : Float
    , transparentcolor : String
    , properties : CustomProperties
    }


{-|

  - `data` List of GIDs. [tilelayer](#TileLayerData) only.
  - `name` Name assigned to this layer
  - `x` Horizontal layer offset in tiles. Always 0.
  - `y` Vertical layer offset in tiles. Always 0.
  - `width` Column count. Same as map width for fixed-size maps.
  - `height` Row count. Same as map height for fixed-size maps.
  - `opacity` Value between 0 and 1
  - `properties` A list of properties (name, value, type).
  - `visible` Whether layer is shown or hidden in editor
-}
type alias TileLayerData =
    { data : List Int
    , height : Int
    , name : String
    , opacity : Float
    , visible : Bool
    , width : Int
    , x : Float
    , y : Float
    , properties : CustomProperties
    }


{-|

  - `name` Name assigned to this layer
  - `x` Horizontal layer offset in tiles. Always 0.
  - `y` Vertical layer offset in tiles. Always 0.
  - `draworder` [`TopDown`](#DrawOrder) (default)
  - `objects` List of objects. objectgroup only.
  - `opacity` Value between 0 and 1
  - `properties` A list of properties (name, value, type).
  - `visible` Whether layer is shown or hidden in editor
-}
type alias ObjectLayerData =
    { draworder : DrawOrder
    , name : String
    , objects : List Object
    , opacity : Float
    , visible : Bool
    , x : Float
    , y : Float
    , properties : CustomProperties
    }


{-| -}
decodeLayer : Decoder Layer
decodeLayer =
    field "type" Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "tilelayer" ->
                        Decode.map TileLayer
                            decodeTileLayer

                    "imagelayer" ->
                        Decode.map ImageLayer
                            decodeImageLayer

                    "objectgroup" ->
                        Decode.map ObjectLayer
                            decodeObjectLayer

                    _ ->
                        Decode.fail ("Invalid layer type: " ++ string)
            )


{-| -}
decodeImageLayer : Decoder ImageLayerData
decodeImageLayer =
    Pipeline.decode ImageLayerData
        |> required "image" Decode.string
        |> required "name" Decode.string
        |> required "opacity" Decode.float
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> optional "transparentcolor" Decode.string "none"
        |> Pipeline.custom propertiesDecoder


{-| -}
decodeTileLayer : Decoder TileLayerData
decodeTileLayer =
    Pipeline.decode (,)
        |> optional "encoding" Decode.string "none"
        |> optional "compression" Decode.string "none"
        |> Decode.andThen
            (\( encoding, compression ) ->
                Pipeline.decode TileLayerData
                    |> required "data" (decodeTileLayerData encoding compression)
                    |> required "height" Decode.int
                    |> required "name" Decode.string
                    |> required "opacity" Decode.float
                    |> required "visible" Decode.bool
                    |> required "width" Decode.int
                    |> required "x" Decode.float
                    |> required "y" Decode.float
                    |> Pipeline.custom propertiesDecoder
            )


decodeTileLayerData : String -> String -> Decoder (List Int)
decodeTileLayerData encoding compression =
    if compression /= "none" then
        Decode.fail "Tile layer compression not supported yet"
    else if encoding == "base64" then
        Decode.string
            |> Decode.andThen
                (\string ->
                    string
                        |> BinaryBase64.decode
                        |> Result.map (\data -> Decode.succeed (convertTilesData data))
                        |> resultExtract (\err -> Decode.fail err)
                )
    else
        Decode.list Decode.int


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


resultExtract : (e -> a) -> Result e a -> a
resultExtract f x =
    -- http://package.elm-lang.org/packages/elm-community/result-extra/2.2.0/Result-Extra
    case x of
        Ok a ->
            a

        Err e ->
            f e


{-| -}
decodeObjectLayer : Decoder ObjectLayerData
decodeObjectLayer =
    Pipeline.decode ObjectLayerData
        |> required "draworder" decodeDrawOrder
        |> required "name" Decode.string
        |> required "objects" (Decode.list decodeObject)
        |> required "opacity" Decode.float
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> Pipeline.custom propertiesDecoder


{-| -}
type Object
    = ObjectPoint ObjectPointData
    | ObjectRectangle ObjectRectangleData
    | ObjectEllipse ObjectRectangleData
    | ObjectPolygon ObjectPolygonData
    | ObjectPolyLine ObjectPolygonData
    | ObjectTile ObjectTileData


when : Decoder a -> (a -> Bool) -> Decoder b -> Decoder b
when checkDecoder expected actualDecoder =
    -- http://package.elm-lang.org/packages/zwilias/json-decode-exploration/5.0.0/Json-Decode-Exploration#check
    checkDecoder
        |> Decode.andThen
            (\actual ->
                if expected actual then
                    actualDecoder
                else
                    Decode.fail <|
                        "Verification failed, expected '"
                            ++ toString expected
                            ++ "'."
            )


{-| -}
decodeObject : Decoder Object
decodeObject =
    let
        point =
            Decode.map ObjectPoint decodeObjectPoint
                |> when (field "point" Decode.bool) ((==) True)

        elipse =
            Decode.map ObjectEllipse decodeObjectRectangle
                |> when (field "ellipse" Decode.bool) ((==) True)

        polygon =
            Decode.map ObjectPolygon (decodeObjectPolygonData "polygon")

        polyline =
            Decode.map ObjectPolyLine (decodeObjectPolygonData "polyline")

        tile =
            Decode.map ObjectTile decodeObjectTile
                |> when (field "gid" Decode.int) ((<) 0)

        rectangle =
            Decode.map ObjectRectangle decodeObjectRectangle
    in
        Decode.oneOf
            [ point
            , elipse
            , tile
            , polygon
            , polyline
            , rectangle
            ]


{-| -}
type alias ObjectPolygonData =
    { height : Float
    , id : Int
    , name : String
    , polygon : List ObjectPolyPoint
    , rotation : Float
    , kind : String
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    , properties : CustomProperties
    }


{-| -}
type alias ObjectPolyPoint =
    { x : Float
    , y : Float
    }


{-| -}
decodeObjectPolyPoint : Decoder ObjectPolyPoint
decodeObjectPolyPoint =
    Decode.map2 ObjectPolyPoint
        (field "x" Decode.float)
        (field "y" Decode.float)


{-| -}
decodeObjectPolygonData : String -> Decoder ObjectPolygonData
decodeObjectPolygonData key =
    Pipeline.decode ObjectPolygonData
        |> required "height" Decode.float
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required key (Decode.list decodeObjectPolyPoint)
        |> required "rotation" Decode.float
        |> required "type" Decode.string
        |> required "visible" Decode.bool
        |> required "width" Decode.float
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> Pipeline.custom propertiesDecoder


{-| -}
type alias ObjectRectangleData =
    { height : Float
    , id : Int
    , name : String
    , rotation : Float
    , kind : String
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    , properties : CustomProperties
    }


{-| -}
decodeObjectRectangle : Decoder ObjectRectangleData
decodeObjectRectangle =
    Pipeline.decode ObjectRectangleData
        |> required "height" Decode.float
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "rotation" Decode.float
        |> required "type" Decode.string
        |> required "visible" Decode.bool
        |> required "width" Decode.float
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> Pipeline.custom propertiesDecoder


{-| -}
type alias ObjectTileData =
    { gid : Int
    , height : Float
    , id : Int
    , name : String
    , rotation : Float
    , kind : String
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    , properties : CustomProperties
    }


{-| -}
decodeObjectTile : Decoder ObjectTileData
decodeObjectTile =
    Pipeline.decode ObjectTileData
        |> required "gid" Decode.int
        |> required "height" Decode.float
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "rotation" Decode.float
        |> required "type" Decode.string
        |> required "visible" Decode.bool
        |> required "width" Decode.float
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> Pipeline.custom propertiesDecoder


{-| -}
type alias ObjectPointData =
    { id : Int
    , name : String
    , rotation : Float
    , kind : String
    , visible : Bool
    , x : Float
    , y : Float
    , properties : CustomProperties
    }


{-| -}
decodeObjectPoint : Decoder ObjectPointData
decodeObjectPoint =
    Pipeline.decode ObjectPointData
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "rotation" Decode.float
        |> required "type" Decode.string
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> Pipeline.custom propertiesDecoder
