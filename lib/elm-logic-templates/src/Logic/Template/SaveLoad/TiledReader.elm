module Logic.Template.SaveLoad.TiledReader exposing (parse)

import Logic.Component as Component
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (WorldReader, combineListInTask, pointData, polygonData, rectangleData, tileArgs, tileDataWith)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (getTilesetByGid)
import Tiled exposing (gidInfo)
import Tiled.Layer
import Tiled.Level
import Tiled.Object
import Tiled.Tileset exposing (Tileset)


parse :
    world
    -> List (Reader.WorldReader world)
    -> Tiled.Level.Level
    -> Loader.TaskTiled world
parse emptyECS readers level start =
    let
        fix =
            Util.levelCommon level
                |> (\{ height, tileheight } ->
                        toFloat (tileheight * height)
                   )
                |> Util.objFix

        readFor f args acc =
            combineListInTask f args readers ( acc.idSource, acc.ecs )
                >> ResourceTask.map
                    (\( idSource, ecs ) ->
                        { acc | idSource = idSource, ecs = ecs }
                    )

        layersTask =
            (Util.levelCommon level).layers
                |> List.foldl
                    (\layer acc ->
                        case layer of
                            Tiled.Layer.Image imageData ->
                                acc
                                    |> ResourceTask.andThen
                                        (\info ->
                                            readFor .layerImage imageData info
                                        )

                            Tiled.Layer.Tile tileData ->
                                acc
                                    |> ResourceTask.andThen
                                        (\info ->
                                            readFor .layerTile (tileDataWith (getTilesetByGid info.tilesets) tileData) info
                                        )

                            Tiled.Layer.Object objectData ->
                                acc
                                    |> ResourceTask.andThen (\info -> objectLayerParser level fix readers info objectData)

                            Tiled.Layer.InfiniteTile tileChunkedData ->
                                acc |> ResourceTask.andThen (readFor .layerInfiniteTile tileChunkedData)
                    )
                    (ResourceTask.andThen (readFor .level level)
                        (ResourceTask.succeed
                            { tilesets = Util.tilesets level, ecs = emptyECS, idSource = 0 }
                            start
                        )
                    )
    in
    ResourceTask.map
        (\{ ecs } -> ecs)
        layersTask


objectLayerParser :
    Tiled.Level.Level
    -> (Tiled.Object.Object -> Tiled.Object.Object)
    -> List (WorldReader world)
    ->
        { c
            | ecs : world
            , idSource : Int
            , tilesets : List Tileset
        }
    -> Tiled.Layer.ObjectData
    ->
        Loader.TaskTiled
            { c
                | ecs : world
                , idSource : Int
                , tilesets : List Tileset
            }
objectLayerParser level fix readers info_ objectData start =
    let
        readFor f args ( layerECS, acc ) =
            combineListInTask f args readers (Entity.create acc.idSource acc.ecs)
                >> ResourceTask.map
                    (\( _, newECS ) ->
                        layerECS
                            |> Entity.create acc.idSource
                            |> Tuple.second
                            |> validateAndUpdate ( layerECS, acc ) newECS
                    )
    in
    objectData.objects
        |> List.foldl
            (\obj ->
                case fix obj of
                    Tiled.Object.Point common ->
                        pointData objectData common
                            |> readFor .objectPoint
                            |> ResourceTask.andThen

                    Tiled.Object.Rectangle info ->
                        rectangleData objectData info
                            |> readFor .objectRectangle
                            |> ResourceTask.andThen

                    Tiled.Object.Ellipse info ->
                        rectangleData objectData info
                            |> readFor .objectEllipse
                            |> ResourceTask.andThen

                    Tiled.Object.Polygon info ->
                        polygonData objectData info
                            |> readFor .objectPolygon
                            |> ResourceTask.andThen

                    Tiled.Object.PolyLine info ->
                        polygonData objectData info
                            |> readFor .objectPolyLine
                            |> ResourceTask.andThen

                    Tiled.Object.Tile data ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                let
                                    args =
                                        tileArgs level objectData data (gidInfo data.gid) (getTilesetByGid info.tilesets)
                                in
                                readFor .objectTile args ( layerECS, info )
                            )
            )
            (ResourceTask.succeed ( Component.empty, info_ ) start)
        >> ResourceTask.map
            (\( _, info ) -> info)


validateAndUpdate : ( a1, { b | ecs : a, idSource : number } ) -> a -> a1 -> ( a1, { b | ecs : a, idSource : number } )
validateAndUpdate ( layerECS, info ) newECS newLayerECS =
    if layerECS == newLayerECS then
        ( layerECS, { info | idSource = info.idSource + 1, ecs = newECS } )

    else
        ( newLayerECS, { info | idSource = info.idSource + 1, ecs = newECS } )
