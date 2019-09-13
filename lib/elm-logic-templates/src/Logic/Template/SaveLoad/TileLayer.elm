module Logic.Template.SaveLoad.TileLayer exposing (TileLayer(..), read)

import Dict exposing (Dict)
import Logic.Component.Singleton as Component
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (animationFraming, hexColor2Vec3, tilesetById, updateTileset)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Tiled.Layer
import Tiled.Tileset exposing (EmbeddedTileData, SpriteAnimation, Tileset)
import WebGL.Texture as WebGL


type TileLayer
    = Tiles
        { uLut : WebGL.Texture
        , uLutSize : Vec2
        , uAtlas : WebGL.Texture
        , uAtlasSize : Vec2
        , uTileSize : Vec2
        , uTransparentColor : Vec3
        , scrollRatio : Vec2

        -- Encoding related
        , data : List Int
        , id : Int
        , firstgid : Int
        }
    | AnimatedTiles
        { uLut : WebGL.Texture
        , uLutSize : Vec2
        , uAtlas : WebGL.Texture
        , uAtlasSize : Vec2
        , uTileSize : Vec2
        , uTransparentColor : Vec3
        , scrollRatio : Vec2
        , animLUT : WebGL.Texture
        , animLength : Int

        -- Encoding related
        , data : List Int
        }


read : Component.Spec (List TileLayer) world -> WorldReader world
read { set, get } =
    { defaultRead
        | layerTile =
            Async
                (\info ->
                    tileLayerNew info >> ResourceTask.map (\parsedLayers ( id, w ) -> ( id, set (get w ++ parsedLayers) w ))
                )
    }


tileLayerNew : Reader.LayerTileData -> Loader.TaskTiled (List TileLayer)
tileLayerNew layerData =
    tileLayer2_ layerData
        >> ResourceTask.map Tuple.first


tileLayer2_ : Reader.LayerTileData -> Loader.TaskTiled ( List TileLayer, List Tileset )
tileLayer2_ tileDataWith =
    splitTileLayerByTileSet2
        (Util.tilesets tileDataWith.level)
        tileDataWith.data
        { cache = [], static = Dict.empty, animated = Dict.empty }
        >> ResourceTask.andThen
            (\{ tilesets, animated, static } ->
                ResourceTask.sequence
                    (tileStaticLayerBuilder2 tileDataWith static ++ tileAnimatedLayerBuilder2 tileDataWith animated)
                    >> ResourceTask.map (\layers -> ( layers, tilesets ))
            )


splitTileLayerByTileSet2 tilesets dataLeft ({ cache, static, animated } as acc) =
    let
        getTileset =
            Util.getTilesetByGid tilesets
    in
    case dataLeft of
        gid :: rest ->
            if gid == 0 then
                splitTileLayerByTileSet2 tilesets
                    rest
                    { animated = others 0 animated
                    , cache = 0 :: cache
                    , static = others 0 static
                    }

            else
                case tilesetById tilesets gid of
                    Just t ->
                        case t of
                            Tiled.Tileset.Embedded info ->
                                splitTileLayerByTileSet2 tilesets rest (fillTiles gid info acc)

                            (Tiled.Tileset.Source { firstgid, source }) as was ->
                                Loader.getTileset source firstgid
                                    >> ResourceTask.andThen
                                        (\tileset ->
                                            splitTileLayerByTileSet2
                                                (updateTileset was tileset tilesets [])
                                                dataLeft
                                                acc
                                        )

                            Tiled.Tileset.ImageCollection _ ->
                                splitTileLayerByTileSet2 tilesets rest { acc | cache = 0 :: cache }

                    Nothing ->
                        getTileset gid >> ResourceTask.andThen (\t -> splitTileLayerByTileSet2 (t :: tilesets) dataLeft acc)

        [] ->
            ResourceTask.succeed
                { animated = Dict.values acc.animated
                , static = Dict.values acc.static
                , tilesets = tilesets
                }


tileStaticLayerBuilder2 =
    tileStaticLayerBuilder_ Tiles


tileStaticLayerBuilder_ constructor layerData =
    List.map
        (\( tileset, data ) ->
            let
                layerProps =
                    Util.propertiesWithDefault layerData
            in
            ResourceTask.map2
                (\tileSetImage lut ->
                    constructor
                        { uLut = lut
                        , uLutSize = vec2 (toFloat layerData.width) (toFloat layerData.height)
                        , uAtlas = tileSetImage
                        , uAtlasSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
                        , uTileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                        , uTransparentColor = Maybe.withDefault (vec3 1 0 1) (hexColor2Vec3 tileset.transparentcolor)
                        , scrollRatio = Util.scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps

                        -- Encoding related
                        , data = data
                        , id = layerData.id
                        , firstgid = tileset.firstgid
                        }
                )
                (Loader.getTextureTiled tileset.image)
                (Loader.getTextureTiled (Util.imageBase64 layerData.width data))
        )



--tileAnimatedLayerBuilder :
--    TileData
--    -> List ( ( EmbeddedTileData, List SpriteAnimation ), Image.Pixels )
--    -> List (ReaderTask Layer)


tileAnimatedLayerBuilder2 =
    tileAnimatedLayerBuilder_ AnimatedTiles


tileAnimatedLayerBuilder_ constructor layerData =
    List.map
        (\( ( tileset, anim ), data ) ->
            let
                layerProps =
                    Util.propertiesWithDefault layerData

                animLutData =
                    animationFraming anim

                animLength =
                    List.length animLutData
            in
            Loader.getTextureTiled tileset.image
                >> ResourceTask.andThen
                    (\tileSetImage ->
                        Loader.getTextureTiled (Util.imageBase64 layerData.width data)
                            >> ResourceTask.andThen
                                (\lut ->
                                    Loader.getTextureTiled (Util.imageBase64 animLength animLutData)
                                        >> ResourceTask.map
                                            (\animLUT ->
                                                constructor
                                                    { uLut = lut
                                                    , uLutSize = vec2 (toFloat layerData.width) (toFloat layerData.height)
                                                    , uAtlas = tileSetImage
                                                    , uAtlasSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
                                                    , uTileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                                                    , uTransparentColor = Maybe.withDefault (vec3 1 0 1) (hexColor2Vec3 tileset.transparentcolor)
                                                    , scrollRatio = Util.scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps
                                                    , animLUT = animLUT
                                                    , animLength = animLength

                                                    -- Encoding related
                                                    , data = data
                                                    }
                                            )
                                )
                    )
        )


fillTiles tileId info { cache, static, animated } =
    case Dict.get tileId animated of
        Just ( t_, v ) ->
            { cache = 0 :: cache
            , static = others 0 static
            , animated = animated |> Dict.insert tileId ( t_, 1 :: v ) |> others tileId
            }

        Nothing ->
            case Util.animation info (tileId - info.firstgid) of
                Just anim ->
                    { cache = 0 :: cache
                    , static = others 0 static
                    , animated =
                        animated
                            |> Dict.insert tileId ( ( info, anim ), 1 :: cache )
                            |> others tileId
                    }

                Nothing ->
                    let
                        relativeId =
                            -- First element alway should be 1, 0 is for empty
                            tileId - info.firstgid + 1
                    in
                    case Dict.get info.firstgid static of
                        Just ( t_, v ) ->
                            { cache = 0 :: cache
                            , static =
                                static
                                    |> Dict.insert info.firstgid ( t_, relativeId :: v )
                                    |> others info.firstgid
                            , animated = others 0 animated
                            }

                        Nothing ->
                            { cache = 0 :: cache
                            , static =
                                static
                                    |> Dict.insert info.firstgid ( info, relativeId :: cache )
                                    |> others info.firstgid
                            , animated = others 0 animated
                            }


others : comparable -> Dict comparable ( b, List Int ) -> Dict comparable ( b, List Int )
others =
    updateOthers (prepend 0)


prepend : a -> ( b, List a ) -> ( b, List a )
prepend id ( t, v ) =
    ( t, id :: v )


updateOthers : (a -> a) -> comparable -> Dict comparable a -> Dict comparable a
updateOthers f k =
    Dict.map
        (\k_ v ->
            if k_ == k then
                v

            else
                f v
        )
