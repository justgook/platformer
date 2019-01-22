module Tiled.Util exposing
    ( PropertiesReader
    , firstgid
    , layers
    , levelProps
    , properties
    , splitTileLayerByTileSet
    , tilesetById
    , tilesets
    )

import Dict exposing (Dict)
import Math.Vector3 exposing (Vec3, vec3)
import Set
import Tiled.Layer as Layer exposing (Layer)
import Tiled.Level as Level exposing (Level)
import Tiled.Properties exposing (Properties, Property(..))
import Tiled.Tileset as Tileset exposing (Tileset)


splitTileLayerByTileSet : Layer.TileData -> List Tileset -> List ( Tileset, List Int )
splitTileLayerByTileSet tileLayerData tilesetList =
    tileLayerData.data
        |> List.foldl
            (\tileId ( length, acc ) ->
                let
                    updateDict id =
                        append id

                    insertDict tileset id =
                        ( tileset, List.repeat length 0 ++ [ id ] )

                    others =
                        append 0 |> updateOthers

                    append id =
                        \( t_, v ) -> ( t_, v ++ [ id ] )
                in
                tilesetList
                    |> tilesetById tileId
                    |> Maybe.map
                        (\tileset ->
                            let
                                relativeId =
                                    -- First element alway should be 1, 0 is for empty
                                    tileId - firstgid tileset + 1
                            in
                            acc
                                |> updateOrInsert (updateDict relativeId) (insertDict tileset relativeId) (firstgid tileset)
                                |> others (firstgid tileset)
                        )
                    |> Maybe.withDefault (acc |> others 0)
                    |> Tuple.pair (length + 1)
            )
            ( 0, Dict.empty )
        |> Tuple.second
        |> Dict.values


updateOrInsert : (a -> a) -> a -> comparable -> Dict comparable a -> Dict comparable a
updateOrInsert f1 f2 k d =
    case Dict.get k d of
        Just v ->
            Dict.insert k (f1 v) d

        Nothing ->
            Dict.insert k f2 d


updateOthers : (a -> a) -> comparable -> Dict comparable a -> Dict comparable a
updateOthers f k =
    Dict.map
        (\k_ v ->
            if k_ == k then
                v

            else
                f v
        )


firstgid : Tileset -> Int
firstgid item =
    case item of
        Tileset.Source info ->
            info.firstgid

        Tileset.Embedded info ->
            info.firstgid

        Tileset.ImageCollection info ->
            info.firstgid


tilesetById : Int -> List Tileset -> Maybe Tileset
tilesetById id =
    find
        (\item ->
            case item of
                Tileset.Source _ ->
                    False

                Tileset.Embedded info ->
                    id >= info.firstgid && id < info.firstgid + info.tilecount

                Tileset.ImageCollection info ->
                    id >= info.firstgid && id < info.firstgid + info.tilecount
        )


type alias File =
    String


type alias PropertiesReader =
    { bool : String -> Bool -> Bool
    , int : String -> Int -> Int
    , float : String -> Float -> Float
    , string : String -> String -> String
    , color : String -> Vec3 -> Vec3
    , file : String -> File -> File
    }


levelProps : Level -> PropertiesReader
levelProps level =
    case level of
        Level.Orthogonal info ->
            properties info

        Level.Isometric info ->
            properties info

        Level.Staggered info ->
            properties info

        Level.Hexagonal info ->
            properties info


properties : { a | properties : Properties } -> PropertiesReader
properties dict =
    { bool =
        propWrap dict.properties
            (\r ->
                case r of
                    PropBool i ->
                        Just i

                    _ ->
                        Nothing
            )
    , int =
        propWrap dict.properties
            (\r ->
                case r of
                    PropInt i ->
                        Just i

                    _ ->
                        Nothing
            )
    , float =
        propWrap dict.properties
            (\r ->
                case r of
                    PropFloat i ->
                        Just i

                    _ ->
                        Nothing
            )
    , string =
        propWrap dict.properties
            (\r ->
                case r of
                    PropString i ->
                        Just i

                    _ ->
                        Nothing
            )
    , color =
        propWrap dict.properties
            (\r ->
                case r of
                    PropColor i ->
                        hexColor2Vec3 i

                    _ ->
                        Nothing
            )
    , file =
        propWrap dict.properties
            (\r ->
                case r of
                    PropFile i ->
                        Just i

                    _ ->
                        Nothing
            )
    }


propWrap dict parser key default =
    Dict.get key dict
        |> Maybe.andThen parser
        |> Maybe.withDefault default


hexColor2Vec3 : String -> Maybe Vec3
hexColor2Vec3 str =
    let
        withoutHash =
            if String.startsWith "#" str then
                String.dropLeft 1 str

            else
                str
    in
    case String.toList withoutHash of
        [ r1, r2, g1, g2, b1, b2 ] ->
            let
                makeFloat a b =
                    String.fromList [ '0', 'x', a, b ]
                        |> String.toInt
                        |> Maybe.map (\i -> toFloat i / 255)
            in
            Maybe.map3 vec3 (makeFloat r1 r2) (makeFloat g1 g2) (makeFloat b1 b2)

        _ ->
            Nothing


layers : Level -> List Layer
layers level =
    case level of
        Level.Orthogonal info ->
            info.layers

        Level.Isometric info ->
            info.layers

        Level.Staggered info ->
            info.layers

        Level.Hexagonal info ->
            info.layers


tilesets : Level -> List Tileset
tilesets level =
    case level of
        Level.Orthogonal info ->
            info.tilesets

        Level.Isometric info ->
            info.tilesets

        Level.Staggered info ->
            info.tilesets

        Level.Hexagonal info ->
            info.tilesets


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                find predicate rest
