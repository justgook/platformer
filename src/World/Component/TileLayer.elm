module World.Component.TileLayer exposing (tileLayer)

import Defaults exposing (default)
import Dict exposing (Dict)
import Error exposing (Error(..))
import Image exposing (Order(..))
import Image.BMP exposing (encodeWith)
import Layer
import Math.Vector2 exposing (vec2)
import ResourceTask
import Tiled.Tileset
import Tiled.Util2 exposing (tilesetById, updateTileset)


tileLayer tilesets_ ({ data } as layerData) =
    newSplitTileLayerByTileSet
        tilesets_
        data
        { cache = [], static = Dict.empty, animated = Dict.empty }
        >> ResourceTask.andThenWithCache
            (\{ tilesets, animated, static } ->
                ResourceTask.sequenceWithCache (tileStaticLayerBuilder layerData static ++ tileAnimatedLayerBuilder layerData animated)
                    >> ResourceTask.map (\layers -> ( layers, tilesets ))
            )


newSplitTileLayerByTileSet tilesets dataLeft ({ cache, static, animated } as acc) =
    case dataLeft of
        gid :: rest ->
            if gid == 0 then
                newSplitTileLayerByTileSet tilesets
                    rest
                    { animated = others 0 animated
                    , cache = 0 :: cache
                    , static = others 0 static
                    }

            else
                case tilesetById tilesets gid of
                    Just (Tiled.Tileset.Embedded info) ->
                        newSplitTileLayerByTileSet tilesets rest (fillTiles gid info acc)

                    Just ((Tiled.Tileset.Source { firstgid, source }) as was) ->
                        ResourceTask.getTileset ("/assets/" ++ source) firstgid
                            >> ResourceTask.andThenWithCache
                                (\tileset ->
                                    newSplitTileLayerByTileSet
                                        (updateTileset was tileset tilesets [])
                                        dataLeft
                                        acc
                                )

                    Just (Tiled.Tileset.ImageCollection info) ->
                        newSplitTileLayerByTileSet tilesets rest { acc | cache = 0 :: cache }

                    Nothing ->
                        ResourceTask.failWithCache (Error 5000 ("Not found Tileset for GID:" ++ String.fromInt gid))

        [] ->
            ResourceTask.succeedWithCache
                { animated = Dict.values acc.animated
                , static = Dict.values acc.static
                , tilesets = tilesets
                }


imageOptions =
    let
        opt =
            Image.defaultOptions
    in
    { opt | order = LeftUp }


tileStaticLayerBuilder layerData =
    List.map
        (\( tileset, data ) ->
            let
                layerProps =
                    Tiled.Util2.properties layerData

                tilsetProps =
                    Tiled.Util2.properties tileset
            in
            ResourceTask.getTexture ("/assets/" ++ tileset.image)
                >> ResourceTask.andThenWithCache
                    (\tileSetImage ->
                        ResourceTask.getTexture (encodeWith imageOptions layerData.width layerData.height data)
                            >> ResourceTask.map
                                (\lut ->
                                    Layer.Tiles
                                        { lut = lut
                                        , lutSize = vec2 (toFloat layerData.width) (toFloat layerData.height)
                                        , tileSet = tileSetImage
                                        , tileSetSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
                                        , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                                        , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
                                        , scrollRatio = Tiled.Util2.scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps
                                        }
                                )
                    )
        )


tileAnimatedLayerBuilder layerData =
    List.map
        (\( ( tileset, anim ), data ) ->
            let
                layerProps =
                    Tiled.Util2.properties layerData

                tilsetProps =
                    Tiled.Util2.properties tileset

                animLutData =
                    animationFraming anim

                animLength =
                    List.length animLutData
            in
            ResourceTask.getTexture ("/assets/" ++ tileset.image)
                >> ResourceTask.andThenWithCache
                    (\tileSetImage ->
                        ResourceTask.getTexture (encodeWith imageOptions layerData.width layerData.height data)
                            >> ResourceTask.andThenWithCache
                                (\lut ->
                                    ResourceTask.getTexture (encodeWith Image.defaultOptions animLength 1 animLutData)
                                        >> ResourceTask.map
                                            (\animLUT ->
                                                Layer.AbimatedTiles
                                                    { lut = lut
                                                    , lutSize = vec2 (toFloat layerData.width) (toFloat layerData.height)
                                                    , tileSet = tileSetImage
                                                    , tileSetSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
                                                    , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                                                    , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
                                                    , scrollRatio = Tiled.Util2.scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps
                                                    , animLUT = animLUT
                                                    , animLength = animLength
                                                    }
                                            )
                                )
                    )
        )


animationFraming anim =
    anim
        |> List.concatMap
            (\{ duration, tileid } ->
                List.repeat (toFloat duration / 1000 * default.fps |> floor) tileid
            )


fillTiles tileId info ({ cache, static, animated } as acc) =
    case Dict.get tileId animated of
        Just ( t_, v ) ->
            { cache = 0 :: cache
            , static = others 0 static
            , animated = animated |> Dict.insert tileId ( t_, 1 :: v ) |> others tileId
            }

        Nothing ->
            case animation info (tileId - info.firstgid) of
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


animation : Tiled.Tileset.EmbeddedTileData -> Int -> Maybe (List Tiled.Tileset.SpriteAnimation)
animation { tiles } id =
    Dict.get id tiles |> Maybe.map .animation


others =
    updateOthers (prepend 0)


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
