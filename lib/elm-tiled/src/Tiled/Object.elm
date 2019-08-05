module Tiled.Object exposing
    ( Object(..), decode, encode
    , CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints
    , Common, Dimension, Gid, PolyPoints
    )

{-|

@docs Object, decode, encode
@docs CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints
@docs Common, Dimension, Gid, PolyPoints

-}

import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra exposing (when)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Tiled.Properties as Properties exposing (Properties)


{-| -}
type Object
    = Point (Common {})
    | Rectangle CommonDimension
    | Ellipse CommonDimension
    | Polygon CommonDimensionPolyPoints
    | PolyLine CommonDimensionPolyPoints
    | Tile CommonDimensionGid


{-| Do i really need ID here?
-}
type alias Common a =
    { a
        | id : Int
        , name : String
        , kind : String
        , visible : Bool
        , x : Float
        , y : Float
        , rotation : Float
        , properties : Properties
    }


{-| -}
type alias Dimension a =
    { a
        | width : Float
        , height : Float
    }


{-| -}
type alias Gid =
    Int


{-| -}
type alias PolyPoints =
    List
        { x : Float
        , y : Float
        }


type alias CommonDimension =
    Common (Dimension {})


type alias CommonDimensionGid =
    Common (Dimension { gid : Gid })


type alias CommonDimensionPolyPoints =
    Common
        (Dimension
            { points :
                List
                    { x : Float
                    , y : Float
                    }
            }
        )


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


encodeProps : Properties -> List ( String, Encode.Value )
encodeProps data =
    if Dict.isEmpty data then
        []

    else
        [ ( "properties", Properties.encode data ) ]


{-| -}
encode : Object -> Encode.Value
encode obj =
    let
        common data =
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
                |> common
                |> (++) [ ( "width", Encode.float 0 ), ( "height", Encode.float 0 ), ( "point", Encode.bool True ) ]
                |> Encode.object

        Rectangle data ->
            data
                |> common
                |> (++) (dimension data)
                |> List.sortBy Tuple.first
                |> Encode.object

        Ellipse data ->
            data
                |> common
                |> (++) (dimension data)
                |> (::) ( "ellipse", Encode.bool True )
                |> Encode.object

        Polygon data ->
            data
                |> common
                |> (++) (dimension data)
                |> (::) ( "polygon", Encode.list encodePolyPoint data.points )
                |> Encode.object

        PolyLine data ->
            data
                |> common
                |> (++) (dimension data)
                |> (::) ( "polyline", Encode.list encodePolyPoint data.points )
                |> Encode.object

        Tile data ->
            data
                |> common
                |> (++) (dimension data)
                |> (::) ( "gid", Encode.int data.gid )
                |> Encode.object


{-| -}
decode : Decoder Object
decode =
    let
        point =
            Decode.map Point decodeCommon
                |> when (Decode.field "point" Decode.bool) ((==) True)

        ellipse =
            Decode.map2 commonDimension decodeCommon decodeDimension
                |> Decode.map Ellipse
                |> when (Decode.field "ellipse" Decode.bool) ((==) True)

        polygon =
            Decode.field "polygon" decodePolyPoints
                |> Decode.map3 commonDimensionPolyPoints decodeCommon decodeDimension
                |> Decode.map Polygon

        polyline =
            Decode.field "polyline" decodePolyPoints
                |> Decode.map3 commonDimensionPolyPoints decodeCommon decodeDimension
                |> Decode.map PolyLine

        tile =
            Decode.map3 commonDimensionArgsGid decodeCommon decodeDimension decodeGid
                |> Decode.map Tile
                |> when (Decode.field "gid" Decode.int) ((<) 0)

        rectangle =
            Decode.map2 commonDimension decodeCommon decodeDimension
                |> Decode.map Rectangle
    in
    Decode.oneOf
        [ point
        , ellipse
        , tile
        , polygon
        , polyline
        , rectangle
        ]


decodeCommon : Decoder (Common {})
decodeCommon =
    let
        common id name kind visible x y rotation properties =
            { id = id
            , name = name
            , kind = kind
            , visible = visible
            , x = x
            , y = y
            , rotation = rotation
            , properties = properties
            }
    in
    Decode.succeed common
        |> required "id" Decode.int
        |> required "name" Decode.string
        |> required "type" Decode.string
        |> required "visible" Decode.bool
        |> required "x" Decode.float
        |> required "y" Decode.float
        |> required "rotation" Decode.float
        |> optional "properties" Properties.decode Dict.empty


decodeDimension : Decoder (Dimension {})
decodeDimension =
    let
        dimension width height =
            { width = width
            , height = height
            }
    in
    Decode.succeed dimension
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
