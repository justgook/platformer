module Tiled.Layer exposing
    ( Layer(..), decode, encode
    , TileData, ImageData, ObjectData, DrawOrder(..)
    , decodeDraworder, encodeDraworder
    , Chunk, TileChunkedData
    )

{-|

@docs Layer, decode, encode
@docs TileData, ImageData, ObjectData, DrawOrder, Chunks


# Internal

@docs decodeDraworder, encodeDraworder

-}

import Base64
import Bytes exposing (Endianness(..))
import Bytes.Decode
import Dict
import Inflate exposing (inflateGZip, inflateZLib)
import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Tiled.Object as Object exposing (Object)
import Tiled.Properties as Properties exposing (Properties, Property(..))


{-| -}
type Layer
    = Image ImageData
    | Object ObjectData
    | Tile TileData
    | InfiniteTile TileChunkedData


{-| -}
decode : Decoder Layer
decode =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "tilelayer" ->
                        Decode.oneOf
                            [ Decode.map InfiniteTile decodeTileChunkedData

                            -- |> when (Decode.field "chub" Decode.bool) ((==) True)
                            , Decode.map Tile decodeTile
                            ]

                    "imagelayer" ->
                        Decode.map Image decodeImage

                    "objectgroup" ->
                        Decode.map Object
                            decodeObjectLayer

                    _ ->
                        Decode.fail ("Invalid layer type: " ++ string)
            )


{-| -}
encode : Layer -> Encode.Value
encode l =
    case l of
        -- Tile TileData
        Image data ->
            Encode.object
                [ ( "image", Encode.string data.image )
                , ( "name", Encode.string data.name )
                , ( "id", Encode.int data.id )
                , ( "opacity", Encode.float data.opacity )
                , ( "visible", Encode.bool data.visible )
                , ( "x", Encode.float data.x )
                , ( "y", Encode.float data.y )
                , ( "transparentcolor", Encode.string data.transparentcolor )
                , ( "properties", Properties.encode data.properties )
                , ( "type", Encode.string "imagelayer" )
                ]

        Object data ->
            let
                objects =
                    Encode.list Object.encode data.objects
            in
            Encode.object
                [ ( "draworder", encodeDraworder data.draworder )
                , ( "name", Encode.string data.name )
                , ( "id", Encode.int data.id )
                , ( "objects", objects )
                , ( "opacity", Encode.float data.opacity )
                , ( "visible", Encode.bool data.visible )
                , ( "x", Encode.float data.x )
                , ( "y", Encode.float data.y )
                , ( "properties", Properties.encode data.properties )
                , ( "type", Encode.string "objectgroup" )
                , ( "color", Encode.string data.color )
                ]

        Tile data ->
            Encode.object
                [ ( "id", Encode.int data.id )
                , ( "data", Encode.list Encode.int data.data )
                , ( "name", Encode.string data.name )
                , ( "opacity", Encode.float data.opacity )
                , ( "visible", Encode.bool data.visible )
                , ( "width", Encode.int data.width )
                , ( "height", Encode.int data.height )
                , ( "x", Encode.float data.x )
                , ( "y", Encode.float data.y )
                , ( "properties", Properties.encode data.properties )
                , ( "type", Encode.string "tilelayer" )
                ]

        InfiniteTile data ->
            Encode.object
                [ ( "id", Encode.int data.id )
                , ( "data", Encode.list encodeChunk data.chunks )
                , ( "name", Encode.string data.name )
                , ( "opacity", Encode.float data.opacity )
                , ( "visible", Encode.bool data.visible )
                , ( "width", Encode.int data.width )
                , ( "height", Encode.int data.height )
                , ( "x", Encode.float data.x )
                , ( "y", Encode.float data.y )
                , ( "properties", Properties.encode data.properties )
                , ( "type", Encode.string "tilelayer" )
                ]


{-| -}
decodeImage : Decoder ImageData
decodeImage =
    Decode.succeed ImageData
        |> required "id" Decode.int
        |> required "image" Decode.string
        |> required "name" Decode.string
        |> required "opacity" Decode.float
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> optional "transparentcolor" Decode.string "none"
        |> optional "properties" Properties.decode Dict.empty


{-| -}
decodeObjectLayer : Decoder ObjectData
decodeObjectLayer =
    Decode.succeed ObjectData
        |> required "id" Decode.int
        |> required "draworder" decodeDraworder
        |> required "name" Decode.string
        |> required "objects" (list Object.decode)
        |> required "opacity" Decode.float
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> optional "color" Decode.string "none"
        |> optional "properties" Properties.decode Dict.empty


{-| -}
decodeDraworder : Decoder DrawOrder
decodeDraworder =
    Decode.string
        |> Decode.andThen
            (\result ->
                case result of
                    "topdown" ->
                        Decode.succeed TopDown

                    "index" ->
                        Decode.succeed Index

                    _ ->
                        Decode.fail "Unknow render order"
            )


encodeDraworder : DrawOrder -> Encode.Value
encodeDraworder do =
    (case do of
        TopDown ->
            "topdown"

        Index ->
            "index"
    )
        |> Encode.string


{-| -}
decodeTile : Decoder TileData
decodeTile =
    Decode.succeed Tuple.pair
        |> optional "encoding" Decode.string "none"
        |> optional "compression" Decode.string "none"
        |> Decode.andThen
            (\( encoding, compression ) ->
                Decode.succeed TileData
                    |> required "id" Decode.int
                    |> required "data" (decodeTileData encoding compression)
                    |> required "name" Decode.string
                    |> required "opacity" Decode.float
                    |> required "visible" Decode.bool
                    |> required "width" Decode.int
                    |> required "height" Decode.int
                    |> required "x" Decode.float
                    |> required "y" Decode.float
                    |> optional "properties" Properties.decode Dict.empty
            )


decodeTileChunkedData : Decoder TileChunkedData
decodeTileChunkedData =
    Decode.succeed Tuple.pair
        |> optional "encoding" Decode.string "none"
        |> optional "compression" Decode.string "none"
        |> Decode.andThen
            (\( encoding, compression ) ->
                Decode.succeed TileChunkedData
                    |> required "id" Decode.int
                    |> required "chunks" (Decode.list (decodeChunk encoding compression))
                    |> required "name" Decode.string
                    |> required "opacity" Decode.float
                    |> required "visible" Decode.bool
                    |> required "width" Decode.int
                    |> required "height" Decode.int
                    |> required "startx" Decode.int
                    |> required "starty" Decode.int
                    |> required "x" Decode.float
                    |> required "y" Decode.float
                    |> optional "properties" Properties.decode Dict.empty
            )


decodeTileData : String -> String -> Decoder (List Int)
decodeTileData encoding compression =
    let
        bytesToList onFail bytes =
            bytes
                |> Maybe.andThen (\b -> Bytes.Decode.decode (listOfBytesDecode (Bytes.width b // 4) (Bytes.Decode.unsignedInt32 LE)) b)
                |> Maybe.map List.reverse
                |> Maybe.map Decode.succeed
                |> Maybe.withDefault (Decode.fail onFail)
    in
    if compression == "gzip" then
        Decode.string
            |> Decode.andThen
                (Base64.toBytes
                    >> Maybe.andThen inflateGZip
                    >> bytesToList "Tile layer gzip compression can not decompress"
                )

    else if compression == "zlib" then
        Decode.string
            |> Decode.andThen
                (Base64.toBytes
                    >> Maybe.andThen inflateZLib
                    >> bytesToList "Tile layer zlib compression can not decompress"
                )

    else if compression /= "none" then
        Decode.fail ("Tile layer compression " ++ compression ++ " not supported yet")

    else if encoding == "base64" then
        Decode.string
            |> Decode.andThen
                (\string ->
                    string
                        |> Base64.toBytes
                        |> bytesToList "Tile layer base64 encoded fail to decoding"
                )

    else
        Decode.list Decode.int


listOfBytesDecode : Int -> Bytes.Decode.Decoder a -> Bytes.Decode.Decoder (List a)
listOfBytesDecode len decoder =
    Bytes.Decode.loop ( len, [] ) (listStep decoder)


listStep : Bytes.Decode.Decoder a -> ( Int, List a ) -> Bytes.Decode.Decoder (Bytes.Decode.Step ( Int, List a ) (List a))
listStep decoder ( n, xs ) =
    if n <= 0 then
        Bytes.Decode.succeed (Bytes.Decode.Done xs)

    else
        Bytes.Decode.map (\x -> Bytes.Decode.Loop ( n - 1, x :: xs )) decoder


decodeChunk : String -> String -> Decoder Chunk
decodeChunk encoding compression =
    Decode.succeed Chunk
        |> required "data" (decodeTileData encoding compression)
        |> required "height" Decode.int
        |> required "width" Decode.int
        |> required "x" Decode.int
        |> required "y" Decode.int


encodeChunk : Chunk -> Encode.Value
encodeChunk data =
    [ ( "data", Encode.list Encode.int data.data )
    , ( "height", Encode.int data.height )
    , ( "width", Encode.int data.width )
    , ( "x", Encode.int data.x )
    , ( "y", Encode.int data.y )
    ]
        |> Encode.object


{-|

  - `image` - Image used as background
  - `name` Name assigned to this layer
  - `x` Horizontal layer offset in tiles. Always 0.
  - `y` Vertical layer offset in tiles. Always 0.
  - `opacity` Value between 0 and 1
  - `properties` A list of properties (name, value, type).
  - `visible` Whether layer is shown or hidden in editor

-}
type alias ImageData =
    { id : Int
    , image : String
    , name : String
    , opacity : Float
    , visible : Bool
    , x : Float
    , y : Float
    , transparentcolor : String
    , properties : Properties
    }


{-|

  - `name` Name assigned to this layer
  - `x` Horizontal layer offset in tiles. Always 0.
  - `y` Vertical layer offset in tiles. Always 0.
  - `draworder` [`TopDown`](Tiled.Layer#DrawOrder) (default)
  - `objects` List of objects. objectgroup only.
  - `opacity` Value between 0 and 1
  - `properties` A list of properties (name, value, type).
  - `visible` Whether layer is shown or hidden in editor

-}
type alias ObjectData =
    { id : Int
    , draworder : DrawOrder
    , name : String
    , objects : List Object
    , opacity : Float
    , visible : Bool
    , x : Float
    , y : Float
    , color : String
    , properties : Properties
    }


{-| -}
type DrawOrder
    = TopDown
    | Index


{-|

  - `data` List of GIDs from [`Tileset`](Tiled.Tileset#Tileset).
  - `name` Name assigned to this layer
  - `x` Horizontal layer offset in tiles. Always 0.
  - `y` Vertical layer offset in tiles. Always 0.
  - `width` Column count. Same as map width for fixed-size maps.
  - `height` Row count. Same as map height for fixed-size maps.
  - `opacity` Value between 0 and 1
  - `properties` A list of properties (name, value, type).
  - `visible` Whether layer is shown or hidden in editor

-}
type alias TileData =
    { id : Int
    , data : List Int
    , name : String
    , opacity : Float
    , visible : Bool
    , width : Int
    , height : Int
    , x : Float
    , y : Float
    , properties : Properties
    }


type alias TileChunkedData =
    { id : Int
    , chunks : List Chunk
    , name : String
    , opacity : Float
    , visible : Bool
    , width : Int
    , height : Int
    , startx : Int
    , starty : Int
    , x : Float
    , y : Float
    , properties : Properties
    }


{-|

  - `data` array or string Array of unsigned int (GIDs) or base64-encoded data
  - `height` int Height in tiles
  - `width` int Width in tiles
  - `x` int X coordinate in tiles
  - `y` int Y coordinate in tiles

-}
type alias Chunk =
    { data : List Int
    , height : Int
    , width : Int
    , x : Int
    , y : Int
    }
