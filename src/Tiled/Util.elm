module Tiled.Util exposing (animation, animationFraming, common, firstGid, hexColor2Vec3, levelProps, objFix, properties, scrollRatio, tilesetById, tilesets, updateTileset)

import Defaults exposing (default)
import Dict
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Tiled.Level as Level exposing (Level)
import Tiled.Object
import Tiled.Properties exposing (Properties, Property(..))
import Tiled.Tileset exposing (EmbeddedTileData, SpriteAnimation)


objFix levelHeight obj =
    case obj of
        Tiled.Object.Point c ->
            --Tiled.Object.Point common
            obj

        Tiled.Object.Rectangle c dimension ->
            --Tiled.Object.Rectangle common dimension
            obj

        Tiled.Object.Ellipse c dimension ->
            --Tiled.Object.Ellipse common dimension
            obj

        Tiled.Object.Polygon c dimension polyPoints ->
            --Tiled.Object.Polygon common dimension polyPoints
            obj

        Tiled.Object.PolyLine c dimension polyPoints ->
            --Tiled.Object.PolyLine common dimension polyPoints
            obj

        Tiled.Object.Tile c dimension gid ->
            Tiled.Object.Tile
                { c | y = levelHeight - c.y + dimension.height / 2, x = c.x + dimension.width / 2 }
                dimension
                gid


common level =
    case level of
        Level.Orthogonal info ->
            { backgroundcolor = info.backgroundcolor
            , height = info.height
            , infinite = info.infinite
            , layers = info.layers
            , nextobjectid = info.nextobjectid
            , renderorder = info.renderorder
            , tiledversion = info.tiledversion
            , tileheight = info.tileheight
            , tilesets = info.tilesets
            , tilewidth = info.tilewidth
            , version = info.version
            , width = info.width
            , properties = info.properties
            }

        Level.Isometric info ->
            { backgroundcolor = info.backgroundcolor
            , height = info.height
            , infinite = info.infinite
            , layers = info.layers
            , nextobjectid = info.nextobjectid
            , renderorder = info.renderorder
            , tiledversion = info.tiledversion
            , tileheight = info.tileheight
            , tilesets = info.tilesets
            , tilewidth = info.tilewidth
            , version = info.version
            , width = info.width
            , properties = info.properties
            }

        Level.Staggered info ->
            { backgroundcolor = info.backgroundcolor
            , height = info.height
            , infinite = info.infinite
            , layers = info.layers
            , nextobjectid = info.nextobjectid
            , renderorder = info.renderorder
            , tiledversion = info.tiledversion
            , tileheight = info.tileheight
            , tilesets = info.tilesets
            , tilewidth = info.tilewidth
            , version = info.version
            , width = info.width
            , properties = info.properties
            }

        Level.Hexagonal info ->
            { backgroundcolor = info.backgroundcolor
            , height = info.height
            , infinite = info.infinite
            , layers = info.layers
            , nextobjectid = info.nextobjectid
            , renderorder = info.renderorder
            , tiledversion = info.tiledversion
            , tileheight = info.tileheight
            , tilesets = info.tilesets
            , tilewidth = info.tilewidth
            , version = info.version
            , width = info.width
            , properties = info.properties
            }


scrollRatio : Bool -> PropertiesReader -> Vec2
scrollRatio dual props =
    if dual then
        vec2 (props.float "scrollRatio.x" default.scrollRatio) (props.float "scrollRatio.y" default.scrollRatio)

    else
        vec2 (props.float "scrollRatio" default.scrollRatio) (props.float "scrollRatio" default.scrollRatio)


tilesets : Level -> List Tiled.Tileset.Tileset
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


animationFraming : List { a | duration : Int, tileid : b } -> List b
animationFraming anim =
    anim
        |> List.concatMap
            (\{ duration, tileid } ->
                List.repeat (toFloat duration / 1000 * default.fps |> floor) tileid
            )


updateTileset was now begin end =
    case begin of
        item :: left ->
            if item == was then
                left ++ (now :: end) |> List.reverse

            else
                updateTileset was now left (item :: end)

        [] ->
            end |> List.reverse


animation : EmbeddedTileData -> Int -> Maybe (List SpriteAnimation)
animation { tiles } id =
    Dict.get id tiles
        |> Maybe.andThen
            (\info ->
                if List.length info.animation > 0 then
                    Just info.animation

                else
                    Nothing
            )


tilesetById : List Tiled.Tileset.Tileset -> Int -> Maybe Tiled.Tileset.Tileset
tilesetById tilesets_ id =
    let
        innerfind predicate list =
            case list of
                first :: next :: rest ->
                    if predicate first (Just next) then
                        Just first

                    else
                        innerfind predicate (next :: rest)

                first :: rest ->
                    if predicate first Nothing then
                        Just first

                    else
                        innerfind predicate rest

                [] ->
                    Nothing
    in
    innerfind
        (\item next ->
            case ( item, next ) of
                ( Tiled.Tileset.Source info, Nothing ) ->
                    True

                ( Tiled.Tileset.Source info, Just nextTileset ) ->
                    id >= info.firstgid && id < firstGid nextTileset

                ( Tiled.Tileset.Embedded info, _ ) ->
                    id >= info.firstgid && id < info.firstgid + info.tilecount

                ( Tiled.Tileset.ImageCollection info, _ ) ->
                    id >= info.firstgid && id < info.firstgid + info.tilecount
        )
        tilesets_


firstGid : Tiled.Tileset.Tileset -> Int
firstGid item =
    case item of
        Tiled.Tileset.Source info ->
            info.firstgid

        Tiled.Tileset.Embedded info ->
            info.firstgid

        Tiled.Tileset.ImageCollection info ->
            info.firstgid


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
            maybeMap6
                (\a b c d e f ->
                    vec3 ((a * 16 + b) / 255) ((c * 16 + d) / 255) ((e * 16 + f) / 255)
                )
                (intFromHexChar r1)
                (intFromHexChar r2)
                (intFromHexChar g1)
                (intFromHexChar g2)
                (intFromHexChar b1)
                (intFromHexChar b2)

        _ ->
            Nothing


intFromHexChar : Char -> Maybe Float
intFromHexChar s =
    case s of
        '0' ->
            Just 0

        '1' ->
            Just 1

        '2' ->
            Just 2

        '3' ->
            Just 3

        '4' ->
            Just 4

        '5' ->
            Just 5

        '6' ->
            Just 6

        '7' ->
            Just 7

        '8' ->
            Just 8

        '9' ->
            Just 9

        'a' ->
            Just 10

        'b' ->
            Just 11

        'c' ->
            Just 12

        'd' ->
            Just 13

        'e' ->
            Just 14

        'f' ->
            Just 15

        _ ->
            Nothing


maybeMap6 : (a -> b -> c -> d -> e -> f -> value) -> Maybe a -> Maybe b -> Maybe c -> Maybe d -> Maybe e -> Maybe f -> Maybe value
maybeMap6 func ma mb mc md me mf =
    case ma of
        Nothing ->
            Nothing

        Just a ->
            case mb of
                Nothing ->
                    Nothing

                Just b ->
                    case mc of
                        Nothing ->
                            Nothing

                        Just c ->
                            case md of
                                Nothing ->
                                    Nothing

                                Just d ->
                                    case me of
                                        Nothing ->
                                            Nothing

                                        Just e ->
                                            case mf of
                                                Nothing ->
                                                    Nothing

                                                Just f ->
                                                    Just (func a b c d e f)
