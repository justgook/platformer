module Tiled.Object exposing
    ( Object(..), decode, encode
    , Common, Dimension, Gid, PolyPoints
    )

{-|

@docs Object, decode, encode
@docs Common, Dimension, Gid, PolyPoints

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra exposing (when)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Tiled.Properties as Properties exposing (Properties)


{-| -}
type Object
    = Point Common
    | Rectangle Common Dimension
    | Ellipse Common Dimension
    | Polygon Common Dimension PolyPoints
    | PolyLine Common Dimension PolyPoints
    | Tile Common Dimension Gid


{-| Do i really need ID here?
-}
type alias Common =
    { id : Int
    , name : String
    , kind : String
    , visible : Bool
    , x : Float
    , y : Float
    , rotation : Float
    , properties : Properties
    }


{-| -}
type alias Dimension =
    { width : Float
    , height : Float
    }


{-| -}
type alias Gid =
    Int


{-| -}
type alias PolyPoints =
    List { x : Float, y : Float }


encodeProps data =
    if Dict.isEmpty data then
        []

    else
        [ ( "properties", Properties.encode data ) ]


{-| -}
encode : Object -> Encode.Value
encode obj =
    let
        base data =
            [ ( "id", Encode.int data.id )
            , ( "name", Encode.string data.name )
            , ( "type", Encode.string data.kind )
            , ( "visible", Encode.bool data.visible )
            , ( "x", Encode.float data.x )
            , ( "y", Encode.float data.y )
            , ( "rotation", Encode.float data.rotation )
            ]
                ++ encodeProps data.properties

        dimension data =
            [ ( "width", Encode.float data.width )
            , ( "height", Encode.float data.height )
            ]

        encodePolyPoint { x, y } =
            Encode.object
                [ ( "x", x |> Encode.float )
                , ( "y", y |> Encode.float )
                ]
    in
    case obj of
        Point data ->
            data
                |> base
                |> (++) [ ( "width", Encode.float 0 ), ( "height", Encode.float 0 ), ( "point", Encode.bool True ) ]
                |> Encode.object

        Rectangle data size ->
            data
                |> base
                |> (++) (dimension size)
                |> List.sortBy Tuple.first
                |> Encode.object

        Ellipse data size ->
            data
                |> base
                |> (++) (dimension size)
                |> (::) ( "ellipse", Encode.bool True )
                |> Encode.object

        Polygon data size points ->
            data
                |> base
                |> (++) (dimension size)
                |> (::) ( "polygon", Encode.list encodePolyPoint points )
                |> Encode.object

        PolyLine data size points ->
            data
                |> base
                |> (++) (dimension size)
                |> (::) ( "polyline", Encode.list encodePolyPoint points )
                |> Encode.object

        Tile data size gid ->
            data
                |> base
                |> (++) (dimension size)
                |> (::) ( "gid", Encode.int gid )
                |> Encode.object


{-| -}
decode : Decoder Object
decode =
    let
        point =
            Decode.map Point decodeCommon
                |> when (Decode.field "point" Decode.bool) ((==) True)

        elipse =
            Decode.map2 Ellipse decodeCommon decodeDimension
                |> when (Decode.field "ellipse" Decode.bool) ((==) True)

        polygon =
            Decode.field "polygon" decodePolyPoints
                |> Decode.map3 Polygon decodeCommon decodeDimension

        polyline =
            Decode.field "polyline" decodePolyPoints
                |> Decode.map3 PolyLine decodeCommon decodeDimension

        tile =
            Decode.map3 Tile decodeCommon decodeDimension decodeGid
                |> when (Decode.field "gid" Decode.int) ((<) 0)

        rectangle =
            Decode.map2 Rectangle decodeCommon decodeDimension
    in
    Decode.oneOf
        [ point
        , elipse
        , tile
        , polygon
        , polyline
        , rectangle
        ]


decodeCommon : Decoder Common
decodeCommon =
    Decode.succeed Common
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "type" Decode.string
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> required "rotation" Decode.float
        |> optional "properties" Properties.decode Dict.empty


decodeDimension : Decoder Dimension
decodeDimension =
    Decode.succeed Dimension
        |> required "width" Decode.float
        |> required "height" Decode.float


decodePolyPoints : Decoder PolyPoints
decodePolyPoints =
    Decode.succeed (\x y -> { x = x, y = y })
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> Decode.list


decodeGid : Decoder Gid
decodeGid =
    Decode.field "gid" Decode.int
