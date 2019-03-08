module World.Component.ObjetLayer exposing (objectLayer, validateAndUpdate)

import Error exposing (Error(..))
import Layer exposing (Layer)
import Logic.Component as Component
import Logic.Entity as Entity exposing (EntityID)
import ResourceTask exposing (CacheTask, ResourceTask)
import Tiled exposing (gidInfo)
import Tiled.Layer
import Tiled.Object
import Tiled.Tileset exposing (Tileset)
import Tiled.Util exposing (tilesetById)
import World.Component.Common exposing (GetTileset, Read(..), Reader, combine, commonDimensionArgs, commonDimensionPolyPointsArgs, tileArgs)
import World.Component.Util exposing (getTilesetByGid)


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
    -> CacheTask
    ->
        ResourceTask
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
        |> List.foldr
            (\obj ->
                case fix obj of
                    Tiled.Object.Point common ->
                        readFor .objectPoint common |> ResourceTask.andThen

                    Tiled.Object.Rectangle common dimension ->
                        commonDimensionArgs common dimension
                            |> readFor .objectRectangle
                            |> ResourceTask.andThen

                    Tiled.Object.Ellipse common dimension ->
                        commonDimensionArgs common dimension
                            |> readFor .objectEllipse
                            |> ResourceTask.andThen

                    Tiled.Object.Polygon common dimension polyPoints ->
                        commonDimensionPolyPointsArgs common dimension polyPoints
                            |> readFor .objectPolygon
                            |> ResourceTask.andThen

                    Tiled.Object.PolyLine common dimension polyPoints ->
                        commonDimensionPolyPointsArgs common dimension polyPoints
                            |> readFor .objectPolyLine
                            |> ResourceTask.andThen

                    Tiled.Object.Tile common dimension gid ->
                        ResourceTask.andThen
                            (\( layerECS, info ) ->
                                let
                                    args =
                                        tileArgs common dimension (gidInfo gid) (getTilesetByGid info.tilesets)
                                in
                                readFor .objectTile args ( layerECS, info )
                            )
            )
            (ResourceTask.succeed ( Component.empty, info_ ) start)
        >> ResourceTask.map
            (\( layer, info ) ->
                { info | layers = Layer.Object layer :: info.layers }
            )


validateAndUpdate : ( a1, { b | ecs : a, idSource : number } ) -> a -> a1 -> ( a1, { b | ecs : a, idSource : number } )
validateAndUpdate ( layerECS, info ) newECS newLayerECS =
    if layerECS == newLayerECS then
        ( layerECS, { info | idSource = info.idSource + 1, ecs = newECS } )

    else
        ( newLayerECS, { info | idSource = info.idSource + 1, ecs = newECS } )
