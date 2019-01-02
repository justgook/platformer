module Tiled.Level exposing
    ( Level(..)
    , decode, encode
    , LevelData, StaggeredLevelData, ExtensibleLevelData
    )

{-|

@docs Level
@docs decode, encode


# Level Data

@docs LevelData, StaggeredLevelData, ExtensibleLevelData

-}

import Dict
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Tiled.Helper exposing (indexedFoldl)
import Tiled.Layer as Layer exposing (Layer)
import Tiled.Properties as Properties exposing (Properties)
import Tiled.Tileset as Tileset exposing (Tileset)


{-| Tiled can export maps as JSON files. That is elm representation of that structure.
-}
type Level
    = Orthogonal LevelData
    | Isometric LevelData
    | Staggered StaggeredLevelData
    | Hexagonal StaggeredLevelData


{-| -}
type alias ExtensibleLevelData addition =
    { addition
        | backgroundcolor : String
        , height : Int
        , infinite : Bool
        , layers : List Layer
        , nextobjectid : Int
        , renderorder : RenderOrder
        , tiledversion : String
        , tileheight : Int
        , tilesets : List Tileset
        , tilewidth : Int
        , version : Float
        , width : Int
        , properties : Properties
    }


{-| -}
type alias LevelData =
    ExtensibleLevelData {}


{-| -}
type alias StaggeredLevelData =
    ExtensibleLevelData
        { hexsidelength : Int
        , staggeraxis : Axis
        , staggerindex : OddOrEven
        }


{-| -}
type RenderOrder
    = RightDown
    | RightUp
    | LeftDown
    | LeftUp


type Axis
    = X
    | Y


type OddOrEven
    = Odd
    | Even


{-| -}
decode : Decoder Level
decode =
    Decode.field "orientation" Decode.string
        |> Decode.andThen
            (\orientation ->
                case orientation of
                    "orthogonal" ->
                        decodeLevelData |> Decode.map Orthogonal

                    "isometric" ->
                        decodeLevelData |> Decode.map Isometric

                    "staggered" ->
                        decodeStaggeredlevelData |> Decode.map Staggered

                    "hexagonal" ->
                        decodeStaggeredlevelData |> Decode.map Hexagonal

                    _ ->
                        Decode.fail ("Unknown orientation `" ++ orientation ++ "`")
            )


{-| -}
encode : Level -> Encode.Value
encode l =
    let
        result =
            case l of
                Orthogonal data ->
                    encodeLevelData data [ ( "orientation", Encode.string "orthogonal" ) ]

                Isometric data ->
                    encodeLevelData data [ ( "orientation", Encode.string "isometric" ) ]

                Staggered data ->
                    encodeStaggered data
                        ++ [ ( "orientation", Encode.string "staggered" ) ]
                        |> encodeLevelData data

                Hexagonal data ->
                    encodeStaggered data
                        |> (++) [ ( "orientation", Encode.string "hexagonal" ) ]
                        |> encodeLevelData data
    in
    result


encodeLevelData : ExtensibleLevelData a -> List ( String, Encode.Value ) -> Encode.Value
encodeLevelData record addition =
    let
        layers =
            Encode.list Layer.encode record.layers
    in
    Encode.object
        ([ ( "backgroundcolor", Encode.string <| record.backgroundcolor )
         , ( "height", Encode.int <| record.height )
         , ( "infinite", Encode.bool <| record.infinite )
         , ( "layers", layers )
         , ( "nextlayerid", Encode.int <| List.length record.layers )
         , ( "nextobjectid", Encode.int <| record.nextobjectid )
         , ( "renderorder", encodeRenderOrder <| record.renderorder )
         , ( "tiledversion", Encode.string <| record.tiledversion )
         , ( "tileheight", Encode.int <| record.tileheight )
         , ( "tilesets", Encode.list Tileset.encode record.tilesets )
         , ( "tilewidth", Encode.int <| record.tilewidth )
         , ( "type", Encode.string <| "map" )
         , ( "version", Encode.float <| record.version )
         , ( "width", Encode.int <| record.width )
         ]
            ++ addition
            ++ (if Dict.isEmpty record.properties then
                    []

                else
                    [ ( "properties", Properties.encode record.properties ) ]
               )
        )


encodeStaggered : StaggeredLevelData -> List ( String, Encode.Value )
encodeStaggered record =
    let
        staggeraxis =
            case record.staggeraxis of
                X ->
                    "x"

                Y ->
                    "y"

        staggerindex =
            case record.staggerindex of
                Odd ->
                    "odd"

                Even ->
                    "even"
    in
    [ ( "hexsidelength", Encode.int <| record.hexsidelength )
    , ( "staggeraxis", Encode.string <| staggeraxis )
    , ( "staggerindex", Encode.string <| staggerindex )
    ]


encodeRenderOrder ro =
    (case ro of
        RightDown ->
            "right-down"

        RightUp ->
            "right-up"

        LeftDown ->
            "right-down"

        LeftUp ->
            "right-down"
    )
        |> Encode.string


decodeLevelData : Decoder LevelData
decodeLevelData =
    Decode.succeed
        (\backgroundcolor height infinite layers nextobjectid renderorder tiledversion tileheight tilesets tilewidth version width props ->
            { backgroundcolor = backgroundcolor
            , height = height
            , infinite = infinite
            , layers = layers
            , nextobjectid = nextobjectid
            , renderorder = renderorder
            , tiledversion = tiledversion
            , tileheight = tileheight
            , tilesets = tilesets
            , tilewidth = tilewidth
            , version = version
            , width = width
            , properties = props
            }
        )
        |> optional "backgroundcolor" Decode.string ""
        |> required "height" Decode.int
        |> required "infinite" Decode.bool
        |> required "layers" (Decode.list Layer.decode)
        |> required "nextobjectid" Decode.int
        |> required "renderorder" decodeRenderOrder
        |> required "tiledversion" Decode.string
        |> required "tileheight" Decode.int
        |> required "tilesets" (Decode.list Tileset.decode)
        |> required "tilewidth" Decode.int
        |> required "version" Decode.float
        |> required "width" Decode.int
        |> optional "properties" Properties.decode Dict.empty


decodeStaggeredlevelData : Decoder StaggeredLevelData
decodeStaggeredlevelData =
    Decode.succeed
        (\backgroundcolor height infinite layers nextobjectid renderorder tiledversion tileheight tilesets tilewidth version width props hexsidelength staggeraxis staggerindex ->
            { backgroundcolor = backgroundcolor
            , height = height
            , hexsidelength = hexsidelength
            , infinite = infinite
            , layers = layers
            , nextobjectid = nextobjectid
            , renderorder = renderorder
            , staggeraxis = staggeraxis
            , staggerindex = staggerindex
            , tiledversion = tiledversion
            , tileheight = tileheight
            , tilesets = tilesets
            , tilewidth = tilewidth
            , version = version
            , width = width
            , properties = props
            }
        )
        |> optional "backgroundcolor" Decode.string ""
        |> required "height" Decode.int
        |> required "infinite" Decode.bool
        |> required "layers" (Decode.list Layer.decode)
        |> required "nextobjectid" Decode.int
        |> required "renderorder" decodeRenderOrder
        |> required "tiledversion" Decode.string
        |> required "tileheight" Decode.int
        |> required "tilesets" (Decode.list Tileset.decode)
        |> required "tilewidth" Decode.int
        |> required "version" Decode.float
        |> required "width" Decode.int
        |> optional "properties" Properties.decode Dict.empty
        |> required "hexsidelength" Decode.int
        |> required "staggeraxis" decodeAxis
        |> required "staggerindex" decodeOddOrEven


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


decodeAxis : Decoder Axis
decodeAxis =
    Decode.string
        |> Decode.andThen
            (\a ->
                case a of
                    "x" ->
                        Decode.succeed X

                    "y" ->
                        Decode.succeed Y

                    _ ->
                        Decode.fail <| "Uknown axis `" ++ a ++ "`"
            )


decodeOddOrEven : Decoder OddOrEven
decodeOddOrEven =
    Decode.string
        |> Decode.andThen
            (\a ->
                case a of
                    "odd" ->
                        Decode.succeed Odd

                    "even" ->
                        Decode.succeed Even

                    _ ->
                        Decode.fail <| "Uknown axis `" ++ a ++ "`"
            )
