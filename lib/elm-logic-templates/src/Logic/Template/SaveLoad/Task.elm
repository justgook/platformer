module Logic.Template.SaveLoad.Task exposing (load)

import Logic.Component.Singleton as Component
import Logic.Launcher as Launcher
import Logic.Template.Component.Layer exposing (Layer)
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Reader, combine, tileDataWith)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.Util as Util exposing (getTilesetByGid, objFix)
import Logic.Template.SaveLoad.Layer.ImageLayer exposing (imageLayer)
import Logic.Template.SaveLoad.Layer.ObjetLayer exposing (objectLayer)
import Logic.Template.SaveLoad.Layer.TileLayer exposing (tileLayer)
import Task exposing (Task)
import Tiled.Layer


load : Component.Spec (List Layer) world -> String -> world -> List (Reader world) -> Task Launcher.Error world
load spec levelUrl empty readers =
    ResourceTask.init
        |> Reader.getLevel levelUrl
        |> ResourceTask.andThen (init spec empty readers)
        |> ResourceTask.toTask


init spec emptyECS readers level start =
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
    ResourceTask.map
        (\{ layers, ecs } ->
            spec.set (layers |> List.reverse) ecs
        )
        layersTask
