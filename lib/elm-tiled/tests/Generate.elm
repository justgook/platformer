module Generate exposing (layer, object, properties, tileset)

import Dict exposing (Dict)
import Fuzz exposing (Fuzzer)
import Generate.Util exposing (rangeList)
import Tiled.Layer as Layer exposing (Layer(..))
import Tiled.Object exposing (Common, CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints, Dimension, Gid, Object(..), PolyPoints)
import Tiled.Properties exposing (Properties, Property(..))
import Tiled.Tileset as Tileset exposing (Tileset(..))


maxInt : Int
maxInt =
    2147483647


fuzzId : Fuzzer Int
fuzzId =
    Fuzz.intRange 1 maxInt


tileset =
    { source = Fuzz.map Tileset.Source source
    , embedded = Fuzz.map Tileset.Embedded embedded
    , imageCollection = Fuzz.map Tileset.ImageCollection imageCollection
    }


layer : Fuzzer Layer
layer =
    let
        imageData =
            Fuzz.map Layer.ImageData fuzzId
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.bool
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap properties

        objectData =
            Fuzz.map Layer.ObjectData fuzzId
                |> Fuzz.andMap draworder
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap (Fuzz.list object)
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.bool
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap properties

        tileData =
            Fuzz.map Layer.TileData fuzzId
                |> Fuzz.andMap (Fuzz.list fuzzId)
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.bool
                |> Fuzz.andMap Fuzz.int
                |> Fuzz.andMap Fuzz.int
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap properties
    in
    Fuzz.oneOf
        [ Fuzz.map Layer.Image imageData
        , Fuzz.map Layer.Object objectData
        , Fuzz.map Layer.Tile tileData
        ]


property : Fuzzer Property
property =
    Fuzz.oneOf
        [ Fuzz.map PropBool Fuzz.bool
        , Fuzz.map PropInt Fuzz.int
        , Fuzz.map PropFloat Fuzz.float
        , Fuzz.map PropString Fuzz.string
        , Fuzz.map PropColor Fuzz.string
        , Fuzz.map PropFile Fuzz.string
        ]


properties : Fuzzer Properties
properties =
    Fuzz.tuple ( Fuzz.string, property )
        |> Fuzz.list
        |> Fuzz.map Dict.fromList


propertiesLimit : Int -> Fuzzer Properties
propertiesLimit max =
    Fuzz.tuple ( Fuzz.string, property )
        |> rangeList 0 max
        |> Fuzz.map Dict.fromList


propertiesLimit2 : Int -> Int -> Fuzzer Properties
propertiesLimit2 min max =
    Fuzz.tuple ( Fuzz.string, property )
        |> rangeList min max
        |> Fuzz.map Dict.fromList



--oneProperty : Fuzzer Properties
--oneProperty =
--    Fuzz.tuple ( Fuzz.string, Fuzz.map PropBool Fuzz.bool )
--        |> Fuzz.map (List.singleton >> Dict.fromList)


object : Fuzzer Object
object =
    let
        common : Fuzzer (Common {})
        common =
            Fuzz.map common_ Fuzz.int
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap Fuzz.string
                |> Fuzz.andMap Fuzz.bool
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap Fuzz.float
                |> Fuzz.andMap (propertiesLimit 5)

        common_ id name kind visible x y rotation properties_ =
            { id = id
            , name = name
            , kind = kind
            , visible = visible
            , x = x
            , y = y
            , rotation = rotation
            , properties = properties_
            }

        dimension : Fuzzer (Dimension {})
        dimension =
            Fuzz.map2 dimension_ Fuzz.float Fuzz.float

        dimension_ width height =
            { width = width
            , height = height
            }

        polyPoints : Fuzzer PolyPoints
        polyPoints =
            Fuzz.map2 (\p1 p2 -> { x = p1, y = p2 }) Fuzz.float Fuzz.float
                |> rangeList 0 1
    in
    Fuzz.oneOf
        [ Fuzz.map Point common
        , Fuzz.map Rectangle (Fuzz.map2 commonDimension common dimension)
        , Fuzz.map Ellipse (Fuzz.map2 commonDimension common dimension)
        , Fuzz.map Polygon (Fuzz.map3 commonDimensionPolyPoints common dimension polyPoints)
        , Fuzz.map PolyLine (Fuzz.map3 commonDimensionPolyPoints common dimension polyPoints)
        , Fuzz.map Tiled.Object.Tile (Fuzz.map3 commonDimensionArgsGid common dimension (Fuzz.intRange 1 maxInt))
        ]


draworder : Fuzzer Layer.DrawOrder
draworder =
    Fuzz.oneOf [ Fuzz.constant Layer.Index, Fuzz.constant Layer.TopDown ]


source =
    Fuzz.map2 Tileset.SourceTileData Fuzz.int Fuzz.string


objectgroup : Fuzzer Tileset.TilesDataObjectgroup
objectgroup =
    Fuzz.map Tileset.TilesDataObjectgroup draworder
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.list object)
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.bool
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int


animation : Fuzzer Tileset.SpriteAnimation
animation =
    Fuzz.map2 Tileset.SpriteAnimation Fuzz.int fuzzId


tilesData : Fuzzer Tileset.TilesData
tilesData =
    let
        build data =
            Fuzz.map3
                (\a b c ->
                    { animation = a
                    , objectgroup = b
                    , properties = c
                    }
                )
                data.a
                data.b
                data.c

        none =
            { a = animation |> rangeList 0 5
            , b = Fuzz.maybe objectgroup
            , c = propertiesLimit 10
            }

        all =
            { a = animation |> rangeList 1 5
            , b = Fuzz.map Just objectgroup
            , c = propertiesLimit2 1 10
            }
    in
    Fuzz.oneOf
        [ build all
        , build { none | a = all.a }
        , build { none | b = all.b }
        , build { none | c = all.c }
        ]



--    Fuzz.map3
--        (\a b c ->
--            { animation = a
--            , objectgroup = b
--            , properties = c
--            }
--        )
--        (animation |> rangeList 0 5)
--        (Fuzz.maybe objectgroup)
--        (propertiesLimit 10)


imageCollectionTileDataTile =
    Fuzz.map
        (\a b c d e f ->
            { image = a
            , imageheight = b
            , imagewidth = c
            , animation = d
            , objectgroup = e
            , properties = f
            }
        )
        Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap (animation |> rangeList 0 1)
        |> Fuzz.andMap (Fuzz.maybe objectgroup)
        |> Fuzz.andMap (propertiesLimit 5)


embedded =
    Fuzz.map Tileset.EmbeddedTileData Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap (Fuzz.tuple ( fuzzId, tilesData ) |> Fuzz.list |> Fuzz.map Dict.fromList)
        |> Fuzz.andMap (propertiesLimit 3)


imageCollection =
    Fuzz.map Tileset.ImageCollectionTileData Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap Fuzz.int
        |> Fuzz.andMap (Fuzz.tuple ( fuzzId, imageCollectionTileDataTile ) |> rangeList 0 1 |> Fuzz.map Dict.fromList)
        |> Fuzz.andMap (propertiesLimit 5)
        |> Fuzz.andMap (Fuzz.maybe imageCollectionGrid)


imageCollectionGrid =
    Fuzz.map Tileset.GridData Fuzz.int
        |> Fuzz.andMap Fuzz.string
        |> Fuzz.andMap Fuzz.int


commonDimension : Common a -> Dimension a -> CommonDimension
commonDimension a b =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = b.width
    , height = b.height
    }


commonDimensionArgsGid : Common a -> Dimension a -> Gid -> CommonDimensionGid
commonDimensionArgsGid a b c =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = b.width
    , height = b.height
    , gid = c
    }


commonDimensionPolyPoints : Common a -> Dimension a -> PolyPoints -> CommonDimensionPolyPoints
commonDimensionPolyPoints a b c =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = b.width
    , height = b.height
    , points = c
    }
