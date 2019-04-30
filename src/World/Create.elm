module World.Create exposing (init)

import Logic.GameFlow as Flow
import ResourceTask exposing (CacheTask, ResourceTask)
import Tiled.Layer
import Tiled.Read exposing (combine, tileDataWith)
import Tiled.Read.Util exposing (getTilesetByGid)
import Tiled.Util exposing (objFix)
import World exposing (World(..))
import World.Component.Layer.ImageLayer exposing (imageLayer)
import World.Component.Layer.ObjetLayer exposing (objectLayer)
import World.Component.Layer.TileLayer exposing (tileLayer)



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
                { frame = 0
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
                { ecs
                    | layers =
                        layers
                            |> List.reverse
                }
        )
        layersTask



--<iframe src="https://ghbtns.com/github-btn.html?user=justgook&repo=platformer&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe>
--<iframe src="https://ghbtns.com/github-btn.html?user=justgook&repo=platformer&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe>
