module World.Create exposing (init)

import Logic.GameFlow as Flow
import ResourceTask exposing (CacheTask, ResourceTask)
import Tiled.Layer
import Tiled.Util exposing (objFix)
import World exposing (World(..))
import World.Component.Common exposing (combine, tileDataWith)
import World.Component.ImageLayer exposing (imageLayer)
import World.Component.ObjetLayer exposing (objectLayer)
import World.Component.TileLayer exposing (tileLayer)
import World.Component.Util exposing (getTilesetByGid)



--init : Tiled.Level -> CacheTask -> ResourceTask (List (Layer.Layer object))


init emptyECS readers level start =
    let
        fix =
            Tiled.Util.common level |> (\{ height, tileheight } -> tileheight * height |> toFloat) |> objFix

        readFor f args acc =
            combine f args readers ( acc.idSource, acc.ecs )
                >> ResourceTask.map
                    (\( idSource, ecs ) ->
                        { acc | idSource = idSource, ecs = ecs }
                    )

        layersTask =
            (Tiled.Util.common level).layers
                |> List.foldl
                    (\layer acc ->
                        case layer of
                            Tiled.Layer.Image imageData ->
                                acc
                                    |> ResourceTask.andThen
                                        (\info ->
                                            imageLayer imageData
                                                >> ResourceTask.map (\l -> { info | layers = l :: info.layers })
                                        )

                            Tiled.Layer.Tile tileData ->
                                acc
                                    |> ResourceTask.andThen
                                        (\info ->
                                            tileLayer info.tilesets tileData
                                                >> ResourceTask.map (\( l, t ) -> { info | layers = l ++ info.layers, tilesets = t })
                                        )
                                    |> ResourceTask.andThen
                                        (\info ->
                                            readFor .layerTile (tileDataWith (getTilesetByGid info.tilesets) tileData) info
                                        )

                            Tiled.Layer.Object objectData ->
                                acc
                                    |> ResourceTask.andThen
                                        (\info ->
                                            objectLayer fix readers info objectData
                                        )

                            Tiled.Layer.InfiniteTile _ ->
                                acc
                    )
                    (ResourceTask.andThen (readFor .level level)
                        (ResourceTask.succeed
                            { layers = []
                            , tilesets = Tiled.Util.tilesets level
                            , ecs = emptyECS
                            , idSource = 0
                            }
                            start
                        )
                    )
    in
    ResourceTask.map
        (\{ layers, ecs } ->
            World
                { layers = layers |> List.reverse
                , frame = 0
                , runtime_ = 0
                , flow = Flow.Running

                --                , flow = Flow.SlowMotion { frames = 1000, fps = 3 }
                , env =
                    { height = 0
                    , width = 0
                    , devicePixelRatio = 0
                    , widthRatio = 0
                    }
                }
                ecs
        )
        layersTask
