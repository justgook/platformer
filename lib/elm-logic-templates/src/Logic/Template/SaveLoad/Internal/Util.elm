module Logic.Template.SaveLoad.Internal.Util exposing
    ( TileUV
    , animation
    , animationFraming
    , boolToFloat
    , extractObjectGroup
    , firstGid
    , getCollision
    , getCollisionWith
    , getTilesetByGid
    , hexColor2Vec3
    , imageBase64
    , imageBytes
    , levelCommon
    , levelProps
    , maybeDo
    , objFix
    , objectById
    , objectByIdInLevel
    , objectPosition
    , properties
    , propertiesWithDefault
    , scrollRatio
    , tileProps
    , tileUV
    , tilesetById
    , tilesets
    , updateTileset
    )

import Base64
import Bytes exposing (Bytes)
import Dict
import Image
import Image.Magic
import Logic.Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.Loader exposing (CacheTiled, GetTileset, TaskTiled, getTileset)
import Logic.Template.SaveLoad.Internal.Reader exposing (TileArg)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import Tiled.Layer
import Tiled.Level as Level exposing (Level, LevelData)
import Tiled.Object exposing (Gid, Object(..))
import Tiled.Properties exposing (Properties, Property(..))
import Tiled.Tileset exposing (SpriteAnimation, Tileset(..))


imageBase64 : Int -> List Int -> String
imageBase64 width l =
    imageBytes width l
        |> Base64.fromBytes
        |> Maybe.withDefault ""
        |> (++) "data:image/png;base64,"


imageBytes : Int -> List Int -> Bytes
imageBytes width l =
    Image.fromList width l
        |> Image.Magic.mirror True True
        |> Image.encodePng


maybeDo : (a -> b -> b) -> Maybe a -> b -> b
maybeDo f maybe b =
    case maybe of
        Just a ->
            f a b

        Nothing ->
            b


getTilesetByGid : List Tileset -> GetTileset
getTilesetByGid tilesets_ gid =
    case tilesetById tilesets_ gid of
        Just (Tiled.Tileset.Source info) ->
            getTileset info.source info.firstgid

        Just t ->
            ResourceTask.succeed t

        Nothing ->
            ResourceTask.fail (Error 5001 ("Not found Tileset for GID:" ++ String.fromInt gid))


objectByIdInLevel : Int -> Level -> Maybe Tiled.Object.Object
objectByIdInLevel id level =
    (levelCommon level).layers
        |> exitOnFirst
            (\layer ->
                case layer of
                    Tiled.Layer.Object { objects } ->
                        objectById id objects

                    _ ->
                        Nothing
            )


exitOnFirst : (a -> Maybe b) -> List a -> Maybe b
exitOnFirst f l =
    case l of
        item :: rest ->
            case f item of
                Just a ->
                    Just a

                Nothing ->
                    exitOnFirst f rest

        [] ->
            Nothing


objectById : Int -> List Tiled.Object.Object -> Maybe Tiled.Object.Object
objectById id l =
    find (objectId >> (==) id) l


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


objectPosition : Tiled.Object.Object -> { x : Float, y : Float }
objectPosition obj =
    case obj of
        Point { x, y } ->
            { x = x, y = y }

        Rectangle { x, y } ->
            { x = x, y = y }

        Ellipse { x, y } ->
            { x = x, y = y }

        Polygon { x, y } ->
            { x = x, y = y }

        PolyLine { x, y } ->
            { x = x, y = y }

        Tile { x, y } ->
            { x = x, y = y }


objectId : Tiled.Object.Object -> Int
objectId obj =
    case obj of
        Point { id } ->
            id

        Rectangle { id } ->
            id

        Ellipse { id } ->
            id

        Polygon { id } ->
            id

        PolyLine { id } ->
            id

        Tile { id } ->
            id


extractObjectGroup : Int -> Tileset -> Maybe Tiled.Tileset.TilesDataObjectgroup
extractObjectGroup gid t_ =
    case t_ of
        Embedded t ->
            Dict.get (gid - t.firstgid) t.tiles
                |> Maybe.andThen .objectgroup

        _ ->
            Nothing


extractObjectGroupWith : Int -> Tileset -> Maybe ( Tiled.Tileset.TilesDataObjectgroup, Tiled.Tileset.EmbeddedTileData )
extractObjectGroupWith gid t_ =
    case t_ of
        Embedded t ->
            Dict.get (gid - t.firstgid) t.tiles
                |> Maybe.andThen .objectgroup
                |> Maybe.map (\a -> ( a, t ))

        _ ->
            Nothing


getCollision : TileArg -> TaskTiled (Maybe Tiled.Tileset.TilesDataObjectgroup)
getCollision info =
    getTilesetByGid (levelCommon info.level).tilesets info.gid
        >> ResourceTask.map
            (\t_ ->
                extractObjectGroup info.gid t_
            )


getCollisionWith : Level -> Gid -> TaskTiled (Maybe ( Tiled.Tileset.TilesDataObjectgroup, Tiled.Tileset.EmbeddedTileData ))
getCollisionWith level gid =
    getTilesetByGid (levelCommon level).tilesets gid
        >> ResourceTask.map
            (\t_ ->
                extractObjectGroupWith gid t_
            )


objFix : Float -> Object -> Object
objFix levelHeight obj =
    case obj of
        Tiled.Object.Point c ->
            Tiled.Object.Point { c | y = levelHeight - c.y }

        Tiled.Object.Rectangle c ->
            Tiled.Object.Rectangle { c | y = levelHeight - c.y }

        Tiled.Object.Ellipse _ ->
            obj

        Tiled.Object.Polygon _ ->
            obj

        Tiled.Object.PolyLine _ ->
            obj

        Tiled.Object.Tile c ->
            Tiled.Object.Tile
                { c | y = levelHeight - c.y + c.height / 2, x = c.x + c.width / 2 }


levelCommon : Level -> LevelData
levelCommon level =
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


scrollRatio : Bool -> PropertiesReaderWithDefault -> Vec2
scrollRatio dual props =
    if dual then
        vec2 (props.float "scrollRatio.x" 1) (props.float "scrollRatio.y" 1)

    else
        vec2 (props.float "scrollRatio" 1) (props.float "scrollRatio" 1)


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
                List.repeat (toFloat duration / 1000 * 60 |> ceiling) tileid
            )


type alias TileUV =
    Vec4


tileUV : Tiled.Tileset.EmbeddedTileData -> Int -> TileUV
tileUV t uIndex =
    let
        grid =
            { x = t.imagewidth // t.tilewidth
            , y = t.imageheight // t.tileheight
            }

        --y = info.uIndex / grid.x |> floor |> toFloat |> (+) 0.5 |> (*) tile.y |> (-) uAtlasSize.y
    in
    { x = modBy grid.x uIndex |> toFloat |> (+) 0.5 |> (*) (toFloat t.tilewidth)
    , y = uIndex // grid.x |> toFloat |> (+) 0.5 |> (*) (toFloat t.tileheight) |> (-) (toFloat t.imageheight)
    , z = toFloat t.tilewidth * 0.5
    , w = toFloat t.tileheight * 0.5
    }
        |> Vec4.fromRecord


updateTileset : a -> a -> List a -> List a -> List a
updateTileset was now begin end =
    case begin of
        item :: left ->
            if item == was then
                left ++ (now :: end) |> List.reverse

            else
                updateTileset was now left (item :: end)

        [] ->
            end |> List.reverse


animation : Tiled.Tileset.EmbeddedTileData -> Int -> Maybe (List SpriteAnimation)
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
                ( Tiled.Tileset.Source _, Nothing ) ->
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


type alias PropertiesReaderWithDefault =
    { bool : String -> Bool -> Bool
    , int : String -> Int -> Int
    , float : String -> Float -> Float
    , string : String -> String -> String
    , color : String -> Vec3 -> Vec3
    , file : String -> File -> File
    }


type alias PropertiesReader =
    { bool : String -> Maybe Bool
    , int : String -> Maybe Int
    , float : String -> Maybe Float
    , string : String -> Maybe String
    , color : String -> Maybe Vec3
    , file : String -> Maybe File
    }


levelProps : Level -> PropertiesReaderWithDefault
levelProps level =
    case level of
        Level.Orthogonal info ->
            propertiesWithDefault info

        Level.Isometric info ->
            propertiesWithDefault info

        Level.Staggered info ->
            propertiesWithDefault info

        Level.Hexagonal info ->
            propertiesWithDefault info


propsNothing_ : PropertiesReader
propsNothing_ =
    { bool = \_ -> Nothing
    , int = \_ -> Nothing
    , float = \_ -> Nothing
    , string = \_ -> Nothing
    , color = \_ -> Nothing
    , file = \_ -> Nothing
    }


tileProps : TileArg -> TaskTiled PropertiesReader
tileProps info =
    getTilesetByGid (levelCommon info.level).tilesets info.gid
        >> ResourceTask.map
            (\t_ ->
                case t_ of
                    Tiled.Tileset.Embedded t ->
                        Dict.get (info.gid - t.firstgid) t.tiles
                            |> Maybe.map properties
                            |> Maybe.withDefault propsNothing_

                    _ ->
                        propsNothing_
            )


propertiesWithDefault : { a | properties : Properties } -> PropertiesReaderWithDefault
propertiesWithDefault object =
    { bool =
        propWrap object.properties
            (\r ->
                case r of
                    PropBool i ->
                        Just i

                    _ ->
                        Nothing
            )
    , int =
        propWrap object.properties
            (\r ->
                case r of
                    PropInt i ->
                        Just i

                    _ ->
                        Nothing
            )
    , float =
        propWrap object.properties
            (\r ->
                case r of
                    PropFloat i ->
                        Just i

                    _ ->
                        Nothing
            )
    , string =
        propWrap object.properties
            (\r ->
                case r of
                    PropString i ->
                        Just i

                    _ ->
                        Nothing
            )
    , color =
        propWrap object.properties
            (\r ->
                case r of
                    PropColor i ->
                        hexColor2Vec3 i

                    _ ->
                        Nothing
            )
    , file =
        propWrap object.properties
            (\r ->
                case r of
                    PropFile i ->
                        Just i

                    _ ->
                        Nothing
            )
    }


properties : { a | properties : Properties } -> PropertiesReader
properties object =
    let
        propWrap_ dict parser key =
            Dict.get key dict
                |> Maybe.andThen parser
    in
    { bool =
        propWrap_ object.properties
            (\r ->
                case r of
                    PropBool i ->
                        Just i

                    _ ->
                        Nothing
            )
    , int =
        propWrap_ object.properties
            (\r ->
                case r of
                    PropInt i ->
                        Just i

                    _ ->
                        Nothing
            )
    , float =
        propWrap_ object.properties
            (\r ->
                case r of
                    PropFloat i ->
                        Just i

                    _ ->
                        Nothing
            )
    , string =
        propWrap_ object.properties
            (\r ->
                case r of
                    PropString i ->
                        Just i

                    _ ->
                        Nothing
            )
    , color =
        propWrap_ object.properties
            (\r ->
                case r of
                    PropColor i ->
                        hexColor2Vec3 i

                    _ ->
                        Nothing
            )
    , file =
        propWrap_ object.properties
            (\r ->
                case r of
                    PropFile i ->
                        Just i

                    _ ->
                        Nothing
            )
    }


propWrap : Dict.Dict comparable v -> (v -> Maybe b) -> comparable -> b -> b
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


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0
