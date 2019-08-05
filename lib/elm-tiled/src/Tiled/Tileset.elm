module Tiled.Tileset exposing
    ( Tileset(..), decode, encode
    , SourceTileData, EmbeddedTileData, ImageCollectionTileData
    , TilesData, ImageCollectionTileDataTile, TilesDataObjectgroup, SpriteAnimation
    , decodeFile
    , GridData
    , decodeTilesData, encodeTilesData
    )

{-|

@docs Tileset, decode, encode
@docs SourceTileData, EmbeddedTileData, ImageCollectionTileData
@docs TilesData, ImageCollectionTileDataTile, TilesDataObjectgroup, SpriteAnimation


## Decode tileset from file

@docs decodeFile


## Internal stuff

@docs GridData


## stuff to delete

@docs decodeTilesData, encodeTilesData

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, hardcoded, optional, required)
import Json.Encode as Encode
import Tiled.Layer as Layer exposing (DrawOrder)
import Tiled.Object as Object exposing (Object)
import Tiled.Properties as Properties exposing (Properties)


{-| -}
type Tileset
    = Source SourceTileData
    | Embedded EmbeddedTileData
    | ImageCollection ImageCollectionTileData


{-| -}
decode : Decoder Tileset
decode =
    Decode.oneOf
        [ decodeEmbeddedTileset (required "firstgid" Decode.int)
        , decodeSourceTileset
        , decodeImageCollectionTileData (required "firstgid" Decode.int)
        ]


decodeFile : Int -> Decoder Tileset
decodeFile firstgid =
    Decode.oneOf
        [ decodeEmbeddedTileset (hardcoded firstgid)
        , decodeImageCollectionTileData (hardcoded firstgid)
        ]


{-| -}
encode : Tileset -> Encode.Value
encode tileset =
    let
        transparentcolor data =
            if data == "none" then
                []

            else
                [ ( "transparentcolor", Encode.string data ) ]

        encodeImageCollectionTileDataTile : ( Int, ImageCollectionTileDataTile ) -> Encode.Value
        encodeImageCollectionTileDataTile ( id, data ) =
            ([ ( "id", Encode.int id )
             , ( "image", Encode.string data.image )
             , ( "imageheight", Encode.int data.imageheight )
             , ( "imagewidth", Encode.int data.imagewidth )
             ]
                |> addAnimationIf data.animation
            )
                ++ (data.objectgroup |> Maybe.map (\a -> [ ( "objectgroup", encodeTilesDataObjectGroup a ) ]) |> Maybe.withDefault [])
                ++ ([] |> encodeProps data.properties)
                |> Encode.object
    in
    case tileset of
        Source { firstgid, source } ->
            Encode.object [ ( "firstgid", Encode.int firstgid ), ( "source", Encode.string source ) ]

        Embedded data ->
            let
                encodeTilesIf d =
                    if Dict.isEmpty d then
                        identity

                    else
                        (::) ( "tiles", Encode.list encodeTilesData (Dict.toList d) )
            in
            (( "columns", Encode.int data.columns )
                :: ( "firstgid", Encode.int data.firstgid )
                :: ( "image", Encode.string data.image )
                :: ( "imageheight", Encode.int data.imageheight )
                :: ( "imagewidth", Encode.int data.imagewidth )
                :: ( "margin", Encode.int data.margin )
                :: ( "name", Encode.string data.name )
                :: ( "spacing", Encode.int data.spacing )
                :: ( "tilecount", Encode.int data.tilecount )
                :: ( "tileheight", Encode.int data.tileheight )
                :: ([]
                        |> encodeProps data.properties
                        |> encodeTilesIf data.tiles
                   )
            )
                ++ (( "tilewidth", Encode.int data.tilewidth ) :: transparentcolor data.transparentcolor)
                |> Encode.object

        ImageCollection data ->
            ([ ( "columns", Encode.int data.columns )
             , ( "firstgid", Encode.int data.firstgid )
             ]
                ++ (data.grid |> Maybe.map (encodeGridData >> Tuple.pair "grid" >> List.singleton) |> Maybe.withDefault [])
                ++ [ ( "margin", Encode.int data.margin )
                   , ( "name", Encode.string data.name )
                   , ( "spacing", Encode.int data.spacing )
                   , ( "tilecount", Encode.int data.tilecount )
                   , ( "tileheight", Encode.int data.tileheight )
                   , ( "tiles", Encode.list encodeImageCollectionTileDataTile (Dict.toList data.tiles) )
                   , ( "tilewidth", Encode.int data.tilewidth )
                   ]
                |> encodeProps data.properties
            )
                |> Encode.object


addAnimationIf : List SpriteAnimation -> (List ( String, Encode.Value ) -> List ( String, Encode.Value ))
addAnimationIf l =
    if l == [] then
        identity

    else
        (::) ( "animation", Encode.list encodeSpriteAnimation l )


encodeTilesData : ( Int, TilesDataPlain a ) -> Encode.Value
encodeTilesData ( id, data ) =
    []
        |> encodeProps data.properties
        |> (++)
            (data.objectgroup
                |> Maybe.map (\a -> [ ( "objectgroup", encodeTilesDataObjectGroup a ) ])
                |> Maybe.withDefault []
            )
        |> addAnimationIf data.animation
        |> (::) ( "id", Encode.int id )
        |> Encode.object


encodeProps : Properties -> (List ( String, Encode.Value ) -> List ( String, Encode.Value ))
encodeProps data =
    if Dict.isEmpty data then
        identity

    else
        (::) ( "properties", Properties.encode data )


encodeTilesDataObjectGroup : TilesDataObjectgroup -> Encode.Value
encodeTilesDataObjectGroup data =
    Encode.object
        [ ( "draworder", Layer.encodeDraworder data.draworder )
        , ( "name", Encode.string data.name )
        , ( "objects", Encode.list Object.encode data.objects )
        , ( "opacity", Encode.int data.opacity )
        , ( "type", Encode.string "objectgroup" )
        , ( "visible", Encode.bool data.visible )
        , ( "x", Encode.int data.x )
        , ( "y", Encode.int data.y )
        ]


encodeSpriteAnimation : { a | duration : Int, tileid : Int } -> Encode.Value
encodeSpriteAnimation data =
    Encode.object
        [ ( "duration", Encode.int data.duration )
        , ( "tileid", Encode.int data.tileid )
        ]


type alias Weird =
    Decoder (Int -> String -> Int -> Int -> Int -> String -> Int -> Int -> Int -> Int -> String -> Dict.Dict Int TilesData -> Properties -> EmbeddedTileData)
    -> Decoder (String -> Int -> Int -> Int -> String -> Int -> Int -> Int -> Int -> String -> Dict.Dict Int TilesData -> Properties -> EmbeddedTileData)


{-| -}
decodeEmbeddedTileset : Weird -> Decoder Tileset
decodeEmbeddedTileset firstgid =
    Decode.succeed EmbeddedTileData
        |> required "columns" Decode.int
        |> firstgid
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
        |> optional "tiles" decodeTiles Dict.empty
        |> optional "properties" Properties.decode Dict.empty
        |> Decode.map Embedded


decodeSourceTileset : Decoder Tileset
decodeSourceTileset =
    Decode.succeed SourceTileData
        |> required "firstgid" Decode.int
        |> required "source" Decode.string
        |> Decode.map Source


decodeTiles : Decoder (Dict Int TilesData)
decodeTiles =
    Decode.list decodeTilesData
        |> Decode.andThen
            (List.foldl
                (\info_ acc ->
                    case info_ of
                        Just info ->
                            acc
                                |> Decode.andThen
                                    (Dict.insert info.id
                                        { objectgroup = info.objectgroup
                                        , animation = info.animation
                                        , properties = info.properties
                                        }
                                        >> Decode.succeed
                                    )

                        Nothing ->
                            acc
                )
                (Decode.succeed Dict.empty)
            )


decodeTilesData : Decoder (Maybe (TilesDataPlain { id : Int }))
decodeTilesData =
    Decode.succeed
        (\a b c d ->
            case ( a, b, Dict.toList c ) of
                ( [], Nothing, [] ) ->
                    Nothing

                _ ->
                    Just
                        { animation = a
                        , objectgroup = b
                        , properties = c
                        , id = d
                        }
        )
        |> optional "animation" (Decode.list decodeSpriteAnimation) []
        |> optional "objectgroup" (Decode.maybe decodeTilesDataObjectgroup) Nothing
        |> optional "properties" Properties.decode Dict.empty
        |> required "id" Decode.int


{-| -}
decodeTilesDataObjectgroup : Decoder TilesDataObjectgroup
decodeTilesDataObjectgroup =
    Decode.succeed TilesDataObjectgroup
        |> required "draworder" Layer.decodeDraworder
        |> required "name" Decode.string
        |> required "objects" (Decode.list Object.decode)
        |> required "opacity" Decode.int
        |> required "visible" Decode.bool
        |> required "x" Decode.int
        |> required "y" Decode.int


{-| -}
decodeSpriteAnimation : Decoder SpriteAnimation
decodeSpriteAnimation =
    Decode.map2 SpriteAnimation
        (Decode.field "duration" Decode.int)
        (Decode.field "tileid" Decode.int)


type alias Weird2 =
    Decoder (Int -> Int -> String -> Int -> Int -> Int -> Int -> Dict.Dict Int ImageCollectionTileDataTile -> Properties -> Maybe GridData -> ImageCollectionTileData)
    -> Decoder (Int -> String -> Int -> Int -> Int -> Int -> Dict.Dict Int ImageCollectionTileDataTile -> Properties -> Maybe GridData -> ImageCollectionTileData)


decodeImageCollectionTileData : Weird2 -> Decode.Decoder Tileset
decodeImageCollectionTileData firstgid =
    Decode.succeed ImageCollectionTileData
        |> required "columns" Decode.int
        |> firstgid
        -- |> required "firstgid" Decode.int
        |> required "margin" Decode.int
        |> required "name" Decode.string
        |> required "spacing" Decode.int
        |> required "tilecount" Decode.int
        |> required "tilewidth" Decode.int
        |> required "tileheight" Decode.int
        |> custom decodeImageCollectionTileDataTiles
        |> optional "properties" Properties.decode Dict.empty
        |> optional "grid" (Decode.map Just decodeGrid) Nothing
        |> Decode.map ImageCollection


decodeImageCollectionTileDataTiles : Decoder (Dict Int ImageCollectionTileDataTile)
decodeImageCollectionTileDataTiles =
    let
        decodeImageTile =
            Decode.succeed
                (\id image imageheight imagewidth animation objectgroup properties ->
                    ( id
                    , { image = image
                      , imageheight = imageheight
                      , imagewidth = imagewidth
                      , animation = animation
                      , objectgroup = objectgroup
                      , properties = properties
                      }
                    )
                )
                |> required "id" Decode.int
                |> required "image" Decode.string
                |> required "imageheight" Decode.int
                |> required "imagewidth" Decode.int
                |> optional "animation" (Decode.list decodeSpriteAnimation) []
                |> optional "objectgroup" (Decode.maybe decodeTilesDataObjectgroup) Nothing
                |> optional "properties" Properties.decode Dict.empty

        -- (Decode.maybe (Decode.field "objectgroup" decodeTilesDataObjectgroup))
        -- (Decode.maybe Properties.decode |> Decode.map (Maybe.withDefault Dict.empty))
        --
    in
    Decode.field "tiles" (Decode.list decodeImageTile)
        |> Decode.map (List.foldl (\( i, v ) acc -> Dict.insert i v acc) Dict.empty)


type alias GridData =
    { height : Int
    , orientation : String
    , width : Int
    }


decodeGrid : Decoder GridData
decodeGrid =
    Decode.succeed GridData
        |> required "height" Decode.int
        |> required "orientation" Decode.string
        |> required "width" Decode.int


encodeGridData : GridData -> Encode.Value
encodeGridData data =
    Encode.object
        [ ( "height", Encode.int data.height )
        , ( "orientation", Encode.string data.orientation )
        , ( "width", Encode.int data.width )
        ]


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
    , tilewidth : Int
    , tileheight : Int
    , tiles : Dict Int ImageCollectionTileDataTile
    , properties : Properties
    , grid : Maybe GridData
    }


{-| -}
type alias ImageCollectionTileDataTile =
    TilesDataPlain
        { image : String
        , imageheight : Int
        , imagewidth : Int
        }


{-|

  - `firstgid` GID corresponding to the first tile in the set
  - `source` url to `EmbeddedTileData`

-}
type alias SourceTileData =
    { firstgid : Int
    , source : String
    }


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
    , properties : Properties
    }


type alias TilesData =
    TilesDataPlain {}


{-| -}
type alias SpriteAnimation =
    { duration : Int
    , tileid : Int
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
type alias TilesDataPlain a =
    { a
        | animation : List SpriteAnimation
        , objectgroup : Maybe TilesDataObjectgroup
        , properties : Properties
    }
