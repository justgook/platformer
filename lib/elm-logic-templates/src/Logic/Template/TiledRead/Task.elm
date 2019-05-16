module Logic.Template.TiledRead.Task exposing (load)

import Logic.Template.TiledRead.Internal.Reader exposing (combine, tileDataWith)
import Logic.Template.TiledRead.Internal.ResourceTask as ResourceTask
import Logic.Template.TiledRead.Internal.Util as Util exposing (getTilesetByGid, objFix)
import Logic.Template.TiledRead.Layer.ImageLayer exposing (imageLayer)
import Logic.Template.TiledRead.Layer.ObjetLayer exposing (objectLayer)
import Logic.Template.TiledRead.Layer.TileLayer exposing (tileLayer)
import Tiled.Layer


load levelUrl empty readers =
    ResourceTask.init
        |> ResourceTask.getLevel levelUrl
        |> ResourceTask.andThen (init empty readers)
        |> ResourceTask.toTask


init emptyECS readers level start =
    let
        fix =
            Util.common level
                |> (\{ height, tileheight } ->
                        toFloat (tileheight * height)
                   )
                |> objFix

        readFor f args acc =
            combine f args readers ( acc.idSource, acc.ecs )
                >> ResourceTask.map
                    (\( idSource, ecs ) ->
                        { acc | idSource = idSource, ecs = ecs }
                    )

        layersTask =
            (Util.common level).layers
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
                            , tilesets = Util.tilesets level
                            , ecs = emptyECS
                            , idSource = 0
                            }
                            start
                        )
                    )
    in
    ResourceTask.map (\{ layers, ecs } -> { ecs | layers = layers |> List.reverse }) layersTask
