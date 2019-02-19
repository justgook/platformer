module World.Create exposing (init)

import Logic.GameFlow as Flow
import ResourceTask exposing (CacheTask, ResourceTask)
import Tiled.Layer
import Tiled.Object
import Tiled.Util
import World exposing (World(..))
import World.Camera as Camera
import World.Component.ImageLayer exposing (imageLayer)
import World.Component.ObjetLayer exposing (objectLayer)
import World.Component.TileLayer exposing (tileLayer)



--init : Tiled.Level -> CacheTask -> ResourceTask (List (Layer.Layer object))


init emptyECS readers level start =
    let
        camera =
            Camera.init level

        fix =
            Tiled.Util.common level |> (\{ height, tileheight } -> tileheight * height |> toFloat) |> objFix

        layersTask =
            (Tiled.Util.common level).layers
                |> List.foldr
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

                            Tiled.Layer.Object objectData ->
                                acc
                                    |> ResourceTask.andThen
                                        (\info ->
                                            objectLayer fix readers info objectData
                                        )

                            Tiled.Layer.InfiniteTile _ ->
                                acc
                     -- ResourceTask.andThen
                     --     (\info ->
                     --         ResourceTask.succeed info
                     --     )
                    )
                    (ResourceTask.succeed
                        { layers = []
                        , tilesets = Tiled.Util.tilesets level
                        , ecs = emptyECS
                        , idSource = 0
                        }
                        start
                    )
    in
    ResourceTask.map
        (\{ layers, ecs } ->
            World
                { camera = camera
                , layers = layers
                , frame = 0
                , runtime_ = 0
                , flow = Flow.Running
                }
                ecs
        )
        layersTask


objFix levelHeight obj =
    case obj of
        Tiled.Object.Point common ->
            --Tiled.Object.Point common
            obj

        Tiled.Object.Rectangle common dimension ->
            --Tiled.Object.Rectangle common dimension
            obj

        Tiled.Object.Ellipse common dimension ->
            --Tiled.Object.Ellipse common dimension
            obj

        Tiled.Object.Polygon common dimension polyPoints ->
            --Tiled.Object.Polygon common dimension polyPoints
            obj

        Tiled.Object.PolyLine common dimension polyPoints ->
            --Tiled.Object.PolyLine common dimension polyPoints
            obj

        Tiled.Object.Tile common dimension gid ->
            Tiled.Object.Tile
                { common | y = levelHeight - common.y + dimension.height / 2, x = common.x + dimension.width / 2 }
                dimension
                gid
