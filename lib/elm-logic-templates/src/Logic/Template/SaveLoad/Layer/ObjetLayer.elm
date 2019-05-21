module Logic.Template.SaveLoad.Layer.ObjetLayer exposing (objectLayer, validateAndUpdate)

import Logic.Component as Component
import Logic.Entity as Entity exposing (EntityID)
import Logic.Template.Component.Layer as Layer exposing (Layer(..))
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Reader, ReaderTask, combine, tileArgs)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Logic.Template.SaveLoad.Internal.Util exposing (getTilesetByGid)
import Tiled exposing (gidInfo)
import Tiled.Layer
import Tiled.Object
import Tiled.Tileset exposing (Tileset)


objectLayer :
    (Tiled.Object.Object -> Tiled.Object.Object)
    -> List (Reader world)
    ->
        { c
            | ecs : world
            , idSource : Int
            , layers : List Layer
            , tilesets : List Tileset
        }
    -> Tiled.Layer.ObjectData
    ->
        ReaderTask
            { c
                | ecs : world
                , idSource : Int
                , layers : List Layer
                , tilesets : List Tileset
            }
objectLayer fix readers info_ objectData start =
    let
        spec =
            { get = identity
            , set = \comps _ -> comps
            }

        readFor f args ( layerECS, acc ) =
            combine f args readers (Entity.create acc.idSource acc.ecs)
                >> ResourceTask.map
                    (\( _, newECS ) ->
                        layerECS
                            |> Entity.create acc.idSource
                            |> Entity.with ( spec, () )
                            |> Tuple.second
                            |> validateAndUpdate ( layerECS, acc ) newECS
                    )
    in
    objectData.objects
        |> List.foldl
            (\obj ->
                case fix obj of
                    Tiled.Object.Point common ->
                        readFor .objectPoint common |> ResourceTask.andThen

                    Tiled.Object.Rectangle info ->
                        info
                            |> readFor .objectRectangle
                            |> ResourceTask.andThen

                    Tiled.Object.Ellipse info ->
                        info
                            |> readFor .objectEllipse
                            |> ResourceTask.andThen

                    Tiled.Object.Polygon info ->
                        info
                            |> readFor .objectPolygon
                            |> ResourceTask.andThen

                    Tiled.Object.PolyLine info ->
                        info
                            |> readFor .objectPolyLine
                            |> ResourceTask.andThen

                    Tiled.Object.Tile data ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                let
                                    args =
                                        tileArgs data (gidInfo data.gid) (getTilesetByGid info.tilesets)
                                in
                                readFor .objectTile args ( layerECS, info )
                            )
            )
            (ResourceTask.succeed ( Component.empty, info_ ) start)
        >> ResourceTask.map
            (\( layer, info ) ->
                { info | layers = Object layer :: info.layers }
            )


validateAndUpdate : ( a1, { b | ecs : a, idSource : number } ) -> a -> a1 -> ( a1, { b | ecs : a, idSource : number } )
validateAndUpdate ( layerECS, info ) newECS newLayerECS =
    if layerECS == newLayerECS then
        ( layerECS, { info | idSource = info.idSource + 1, ecs = newECS } )

    else
        ( newLayerECS, { info | idSource = info.idSource + 1, ecs = newECS } )
