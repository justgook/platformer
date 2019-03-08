module World.Component.Collision exposing (collisions)

import Broad.Grid
import Dict
import ResourceTask
import Tiled.Object exposing (Object(..))
import Tiled.Tileset exposing (Tileset(..))
import Tiled.Util
import World.Component.Common exposing (EcsSpec, Read(..), defaultRead)


collisions =
    let
        spec =
            { get = .collisions
            , set = \comps world -> { world | collisions = comps }
            }
    in
    { spec = spec
    , empty =
        Broad.Grid.empty { xmin = 0, ymin = 0, xmax = 0, ymax = 0 } { cellWidth = 0, cellHeight = 0 }
    , read =
        { defaultRead
            | level =
                Sync
                    (\level ( entityID, world ) ->
                        let
                            { tileheight, tilewidth, width, height } =
                                Tiled.Util.common level

                            boundary =
                                { xmin = 0
                                , ymin = 0
                                , xmax = toFloat (width * tilewidth)
                                , ymax = toFloat (height * tileheight)
                                }

                            newData =
                                Broad.Grid.empty
                                    boundary
                                    { cellWidth = toFloat tilewidth, cellHeight = toFloat tileheight }
                        in
                        ( entityID, spec.set newData world )
                    )
            , layerTile =
                Async
                    (\{ data, width, height, getTilesetByGid } ->
                        recursionSpawn getTilesetByGid data ( 0, Dict.empty, identity )
                            >> ResourceTask.map
                                (\spawn ( mId, world ) ->
                                    let
                                        result =
                                            spawn (spec.get world)
                                                |> Broad.Grid.optimize

                                        newWorld =
                                            spec.set result world
                                    in
                                    ( mId, newWorld )
                                )
                    )
        }
    }


spawnMagic index acc =
    .objects >> List.foldl (\o a -> a >> spawnRect index (identity o)) acc


recursionSpawn get dataLeft ( i, cache, acc ) =
    case dataLeft of
        gid_ :: rest ->
            case ( gid_, Dict.get gid_ cache ) of
                ( 0, _ ) ->
                    recursionSpawn get rest ( i + 1, cache, acc )

                ( _, Just Nothing ) ->
                    recursionSpawn get rest ( i + 1, cache, acc )

                ( _, Just (Just info) ) ->
                    recursionSpawn get rest ( i + 1, cache, spawnMagic i acc info )

                ( gid, Nothing ) ->
                    get gid
                        >> ResourceTask.andThen
                            (\t ->
                                let
                                    cacheValue =
                                        extractObjectData gid t

                                    newAcc =
                                        cacheValue
                                            |> Maybe.map (spawnMagic i acc)
                                            |> Maybe.withDefault acc
                                in
                                recursionSpawn get rest ( i + 1, Dict.insert gid cacheValue cache, newAcc )
                            )

        [] ->
            ResourceTask.succeed acc


objectAABB obj =
    case obj of
        Point { x, y } ->
            { x = x, y = y, width = 0, height = 0 }

        Rectangle { x, y } { width, height } ->
            { x = x, y = y, width = width, height = height }

        Ellipse { x, y } { width, height } ->
            { x = x, y = y, width = width, height = height }

        Polygon { x, y } { width, height } polyPoints ->
            { x = x, y = y, width = width, height = height }

        PolyLine { x, y } { width, height } polyPoints ->
            { x = x, y = y, width = width, height = height }

        Tile { x, y } { width, height } gid ->
            { x = x, y = y, width = width, height = height }


extractObjectData gid t_ =
    case t_ of
        Embedded t ->
            Dict.get (gid - t.firstgid) t.tiles
                |> Maybe.andThen .objectgroup

        _ ->
            Nothing


spawnRect i obj ( table, config ) =
    let
        { x, y, width, height } =
            objectAABB obj

        singleton =
            { get = identity
            , set = \comps _ -> comps
            }

        ( cellW, cellH ) =
            config.cell

        offSetX =
            toFloat (modBy config.rows i)
                * cellW

        offSetY =
            config.rows - 1 - (toFloat i / toFloat config.rows |> floor) |> toFloat |> (*) cellH

        boundary =
            { xmin = offSetX + x
            , xmax = offSetX + x + width
            , ymin = offSetY + cellH - height - y
            , ymax = offSetY + cellH - y
            }

        result =
            Broad.Grid.insert boundary "CollisionType goes Here" ( table, config )
    in
    result
