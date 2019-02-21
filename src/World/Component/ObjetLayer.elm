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
import World.Component.Common exposing (GetTileset, Read(..), Reader, commonDimensionArgs, commonDimensionPolyPointsArgs, tileArgs)


getTilesetByGid : List Tileset -> GetTileset
getTilesetByGid tilesets gid =
    case tilesetById tilesets gid of
        Just (Tiled.Tileset.Source info) ->
            ResourceTask.getTileset ("/assets/" ++ info.source) info.firstgid

        Just t ->
            ResourceTask.succeed t

        Nothing ->
            ResourceTask.fail (Error 5001 ("Not found Tileset for GID:" ++ String.fromInt gid))


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
            combine1 f args readers (Entity.create acc.idSource acc.ecs)
                >> ResourceTask.map
                    (\newECS ->
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


combine1 :
    (reader -> Read world a)
    -> a
    -> List reader
    -> ( EntityID, world )
    -> CacheTask
    -> ResourceTask world
combine1 getKey arg readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None ->
                    combine1 getKey arg rest acc

                Sync f ->
                    combine1 getKey arg rest (f arg acc)

                Async f ->
                    f arg >> ResourceTask.andThen (\f1 -> combine1 getKey arg rest (f1 acc))

        [] ->
            let
                ( _, newECS ) =
                    acc
            in
            ResourceTask.succeed newECS


validateAndUpdate : ( a1, { b | ecs : a, idSource : number } ) -> a -> a1 -> ( a1, { b | ecs : a, idSource : number } )
validateAndUpdate ( layerECS, info ) newECS newLayerECS =
    case ( newECS == info.ecs, layerECS == newLayerECS ) of
        ( True, True ) ->
            ( layerECS, info )

        ( False, True ) ->
            ( layerECS, { info | idSource = info.idSource + 1, ecs = newECS } )

        ( True, False ) ->
            ( newLayerECS, { info | idSource = info.idSource + 1 } )

        ( False, False ) ->
            ( newLayerECS, { info | idSource = info.idSource + 1, ecs = newECS } )
