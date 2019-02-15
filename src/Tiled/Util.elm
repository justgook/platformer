module Tiled.Util exposing
    ( PropertiesReader
    , Tileset
    , common
    , firstGid
    , layers
    , levelProps
    , properties
    , splitTileLayerByTileSet
    , tilesetById3
    , tilesets
    )

import Dict exposing (Dict)
import Error exposing (Error(..))
import Math.Vector3 exposing (Vec3, vec3)
import ResourceManager
import Task
import Tiled.Layer as Layer exposing (Layer)
import Tiled.Level as Level exposing (Level)
import Tiled.Properties exposing (Properties, Property(..))
import Tiled.Tileset


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


others =
    updateOthers (prepand 0)


prepand id =
    \( t_, v ) -> ( t_, id :: v )


splitTileLayerByTileSet : Layer.TileData -> List Tiled.Tileset.Tileset -> { static : List ( Tiled.Tileset.Tileset, List Int ), animated : List ( ( Tiled.Tileset.Tileset, List Tiled.Tileset.SpriteAnimation ), List Int ) }
splitTileLayerByTileSet tileLayerData tilesetList =
    tileLayerData.data
        |> List.foldl
            (\tileId ( cache, static, animated ) ->
                case Dict.get tileId animated of
                    Just ( t_, v ) ->
                        ( 0 :: cache
                        , static |> others 0
                        , animated |> Dict.insert tileId ( t_, 1 :: v ) |> others tileId
                        )

                    Nothing ->
                        case tilesetById3 tilesetList tileId of
                            Just tileset ->
                                let
                                    fGid =
                                        firstGid tileset
                                in
                                case animation tileset (tileId - fGid) of
                                    Just anim ->
                                        ( 0 :: cache
                                        , static |> others 0
                                        , animated |> Dict.insert tileId ( ( tileset, anim ), 1 :: cache ) |> others tileId
                                        )

                                    Nothing ->
                                        let
                                            relativeId =
                                                -- First element alway should be 1, 0 is for empty
                                                tileId - fGid + 1
                                        in
                                        case Dict.get fGid static of
                                            Just ( t_, v ) ->
                                                ( 0 :: cache
                                                , static |> Dict.insert fGid ( t_, relativeId :: v ) |> others fGid
                                                , animated |> others 0
                                                )

                                            Nothing ->
                                                ( 0 :: cache
                                                , static
                                                    |> Dict.insert fGid ( tileset, relativeId :: cache )
                                                    |> others fGid
                                                , animated |> others 0
                                                )

                            Nothing ->
                                ( 0 :: cache
                                , static |> others 0
                                , animated |> others 0
                                )
            )
            ( [], Dict.empty, Dict.empty )
        |> (\( _, static, animated ) ->
                { static = Dict.values static
                , animated = animated |> Dict.values
                }
           )



--rangeMember id dict =
--    rangeMember_ id (Dict.keys dict)
--
--
--rangeMember_ id keys =
--    case keys of
--        (( low, hight ) as result) :: rest ->
--            if id > hight || id < low then
--                rangeMember_ id rest
--
--            else
--                Just result
--
--        [] ->
--            Nothing
--
--updateOrInsert : (a -> a) -> a -> comparable -> Dict comparable a -> Dict comparable a
--updateOrInsert f1 f2 k d =
--    case Dict.get k d of
--        Just v ->
--            Dict.insert k (f1 v) d
--
--        Nothing ->
--            Dict.insert k f2 d
--
--
--tileCount tileset =
--    --TODO remove me for unknown length
--    case tileset of
--        Tiled.Tileset.Embedded info ->
--            info.tilecount
--
--        _ ->
--            0


updateOthers : (a -> a) -> comparable -> Dict comparable a -> Dict comparable a
updateOthers f k =
    Dict.map
        (\k_ v ->
            if k_ == k then
                v

            else
                f v
        )


animation : Tiled.Tileset.Tileset -> Int -> Maybe (List Tiled.Tileset.SpriteAnimation)
animation tileset id =
    case tileset of
        Tiled.Tileset.Embedded { tiles } ->
            Dict.get id tiles |> Maybe.map .animation

        _ ->
            Nothing


firstGid : Tiled.Tileset.Tileset -> Int
firstGid item =
    case item of
        Tiled.Tileset.Source info ->
            info.firstgid

        Tiled.Tileset.Embedded info ->
            info.firstgid

        Tiled.Tileset.ImageCollection info ->
            info.firstgid


type Tileset
    = Embedded Tiled.Tileset.EmbeddedTileData
    | ImageCollection Tiled.Tileset.ImageCollectionTileData



--
--tilesetById2 : List Tiled.Tileset.Tileset -> Int -> Task.Task Error Tileset
--tilesetById2 tilesetList id =
--    let
--        fail code =
--            Error code ("Tileset Not Found for gid" ++ String.fromInt id)
--                |> Task.fail
--
--        download =
--            ResourceManager.getTask
--
--        convert t =
--            case t of
--                Tiled.Tileset.Embedded info ->
--                    Task.succeed (Embedded info)
--
--                Tiled.Tileset.ImageCollection info ->
--                    Task.succeed (ImageCollection info)
--
--                Tiled.Tileset.Source _ ->
--                    fail 1
--
--        find2 list =
--            case list of
--                first :: second :: rest ->
--                    case ( first, firstGid second ) of
--                        ( Tiled.Tileset.Source { firstgid, source }, secondGid ) ->
--                            if id >= firstgid && id < secondGid then
--                                download source (Tiled.Tileset.decodeFile firstgid)
--                                    |> Task.onError (\_ -> fail 2)
--                                    |> Task.andThen convert
--
--                            else
--                                find2 (second :: rest)
--
--                        ( Tiled.Tileset.Embedded info, _ ) ->
--                            if id >= info.firstgid && id < info.firstgid + info.tilecount then
--                                Task.succeed (Embedded info)
--
--                            else
--                                find2 (second :: rest)
--
--                        ( Tiled.Tileset.ImageCollection info, _ ) ->
--                            if id >= info.firstgid && id < info.firstgid + info.tilecount then
--                                Task.succeed (ImageCollection info)
--
--                            else
--                                find2 (second :: rest)
--
--                last :: [] ->
--                    case last of
--                        Tiled.Tileset.Source { firstgid, source } ->
--                            if firstgid < id then
--                                download source (Tiled.Tileset.decodeFile firstgid)
--                                    |> Task.onError (\_ -> fail 4)
--                                    |> Task.andThen convert
--
--                            else
--                                fail 6
--
--                        Tiled.Tileset.Embedded info ->
--                            if id >= info.firstgid && id < info.firstgid + info.tilecount then
--                                Task.succeed (Embedded info)
--
--                            else
--                                fail 7
--
--                        Tiled.Tileset.ImageCollection info ->
--                            if id >= info.firstgid && id < info.firstgid + info.tilecount then
--                                Task.succeed (ImageCollection info)
--
--                            else
--                                fail 8
--
--                [] ->
--                    fail 9
--    in
--    find2 tilesetList
--tilesetById : List Tiled.Tileset.Tileset -> Int -> Maybe Tiled.Tileset.Tileset
--tilesetById tileset id =
--    find
--        (\item ->
--            case item of
--                Tiled.Tileset.Source _ ->
--                    False
--
--                Tiled.Tileset.Embedded info ->
--                    id >= info.firstgid && id < info.firstgid + info.tilecount
--
--                Tiled.Tileset.ImageCollection info ->
--                    id >= info.firstgid && id < info.firstgid + info.tilecount
--        )
--        tileset


tilesetById3 : List Tiled.Tileset.Tileset -> Int -> Maybe Tiled.Tileset.Tileset
tilesetById3 tileset id =
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
        tileset


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
