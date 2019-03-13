module World.Component.Physics exposing (physics, physicsWith)

--physics : EcsSpec { a | dimensions : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)

import Dict
import Physic.Body
import Physics
import ResourceTask
import Tiled.Object exposing (Object(..))
import Tiled.Util
import World.Component.Common exposing (Read(..), defaultRead)
import World.Component.Util exposing (extractObjectData)


physics =
    let
        spec =
            { get = .physics
            , set = \comps world -> { world | physics = comps }
            }
    in
    physicsWith spec


physicsWith spec =
    { spec = spec
    , empty = Physics.empty
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

                            info =
                                spec.get world

                            config =
                                info
                                    |> Physics.getConfig

                            newConfig =
                                { config
                                    | grid =
                                        { boundary = boundary
                                        , cell =
                                            { width = toFloat tilewidth
                                            , height = toFloat tileheight
                                            }
                                        }
                                }
                        in
                        ( entityID, spec.set (Physics.setConfig newConfig info) world )
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
                                                |> Physics.clear

                                        newWorld =
                                            spec.set result world
                                    in
                                    ( mId, newWorld )
                                )
                    )
        }
    }


spawnMagic index acc =
    .objects >> List.foldl (\o a -> a >> spawnRect index o) acc


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


createBody obj offSetX offSetY =
    let
        getX x width =
            offSetX + x + width / 2

        getY y height =
            offSetY - height / 2 - y
    in
    case obj of
        Point { x, y } ->
            Physic.Body.rect (offSetX + x) (offSetY + y) 0 0

        Rectangle { x, y } { width, height } ->
            Physic.Body.rect (getX x width) (getY y height) width height

        Ellipse { x, y } { width, height } ->
            Physic.Body.ellipse (getX x width) (getY y height) width height

        Polygon { x, y } { width, height } polyPoints ->
            Physic.Body.rect (getX x width) (getY y height) width height

        PolyLine { x, y } { width, height } polyPoints ->
            Physic.Body.rect (getX x width) (getY y height) width height

        Tile { x, y } { width, height } gid ->
            Physic.Body.rect (getX x width) (getY y height) width height


spawnRect i obj physicsWorld =
    let
        config =
            Physics.getConfig physicsWorld

        ( cellW, cellH ) =
            ( config.grid.cell.width, config.grid.cell.height )

        rows =
            abs (config.grid.boundary.ymax - config.grid.boundary.ymin) / cellH |> ceiling

        offSetX =
            toFloat (modBy rows i) * cellW

        offSetY =
            rows - 1 - (toFloat i / toFloat rows |> floor) |> toFloat |> (*) cellH |> (+) cellH

        body =
            createBody obj offSetX offSetY
                |> Physic.Body.toStatic

        result =
            Physics.addBody body physicsWorld
    in
    result
