module World.Component.Physics exposing (World, aabb, body, common_)

--physics : EcsSpec { a | dimensions : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)

import Dict
import Physic
import Physic.AABB
import Physic.Narrow.AABB as AABB exposing (AABB)
import Physic.Narrow.Body as Body exposing (Body)
import ResourceTask
import Tiled.Object exposing (Object(..))
import Tiled.Read exposing (Read(..), commonDimensionArgs, defaultRead)
import Tiled.Read.Util exposing (extractObjectData)
import Tiled.Util


type alias World =
    Physic.AABB.World Int


body =
    let
        spec =
            { get = .physics
            , set = \comps world -> { world | physics = comps }
            }
    in
    bodyPhysicsWith spec


bodyPhysicsWith spec =
    let
        updateConfig_ f info =
            Physic.setConfig (f (Physic.getConfig info)) info

        --            vec2 0 -1
    in
    common_ Physic.empty Physic.clear updateConfig_ createEnvBody createDynamicBody Body.withIndex Physic.addBody spec


aabb =
    let
        spec =
            { get = .physics
            , set = \comps world -> { world | physics = comps }
            }
    in
    aabbPhysicsWith spec


aabbPhysicsWith spec =
    let
        updateConfig_ f info =
            Physic.AABB.setConfig (f (Physic.AABB.getConfig info)) info
    in
    common_ Physic.AABB.empty Physic.AABB.clear updateConfig_ createEnvAABB createDynamicAABB AABB.withIndex Physic.AABB.addBody spec



--
--createEnvAABB
--createDynamicAABB
--AABB.withIndex Physic.AABB.addBody spec


common_ empty_ clear updateConfig staticBody indexedBody setIndex addBody spec =
    { spec = spec
    , empty = empty_
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

                            withNewConfig =
                                updateConfig
                                    (\config ->
                                        { config
                                            | grid =
                                                { boundary = boundary
                                                , cell =
                                                    { width = toFloat tilewidth
                                                    , height = toFloat tileheight
                                                    }
                                                }
                                        }
                                    )
                                    info
                        in
                        ( entityID, spec.set withNewConfig world )
                    )
            , layerTile =
                Async
                    (\{ data, getTilesetByGid } ->
                        recursionSpawn staticBody getTilesetByGid data ( 0, Dict.empty, identity )
                            >> ResourceTask.map
                                (\spawn ( mId, world ) ->
                                    let
                                        result =
                                            spawn (spec.get world)
                                                |> clear

                                        newWorld =
                                            spec.set result world
                                    in
                                    ( mId, newWorld )
                                )
                    )
            , objectTile =
                Async
                    (\({ gid, getTilesetByGid } as info) ->
                        getTilesetByGid gid
                            >> ResourceTask.map
                                (\t_ ( mId, world ) ->
                                    extractObjectData gid t_
                                        |> Maybe.map .objects
                                        |> Maybe.andThen List.head
                                        |> Maybe.andThen (indexedBody info)
                                        |> Maybe.map
                                            (\body_ ->
                                                let
                                                    result =
                                                        addBody (setIndex mId body_) (spec.get world)
                                                in
                                                ( mId, spec.set result world )
                                            )
                                        |> Maybe.withDefault ( mId, world )
                                )
                    )
        }
    }


recursionSpawn f get dataLeft ( i, cache, acc ) =
    let
        spawnMagic index acc_ =
            .objects >> List.foldl (\o a -> a >> f index o) acc_
    in
    case dataLeft of
        gid_ :: rest ->
            case ( gid_, Dict.get gid_ cache ) of
                ( 0, _ ) ->
                    recursionSpawn f get rest ( i + 1, cache, acc )

                ( _, Just Nothing ) ->
                    recursionSpawn f get rest ( i + 1, cache, acc )

                ( _, Just (Just info) ) ->
                    recursionSpawn f get rest ( i + 1, cache, spawnMagic i acc info )

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
                                recursionSpawn f get rest ( i + 1, Dict.insert gid cacheValue cache, newAcc )
                            )

        [] ->
            ResourceTask.succeed acc


createEnvBody i obj physicsWorld =
    let
        config =
            Physic.getConfig physicsWorld

        ( cellW, cellH ) =
            ( config.grid.cell.width, config.grid.cell.height )

        rows =
            abs (config.grid.boundary.ymax - config.grid.boundary.ymin) / cellH |> ceiling

        offSetX =
            toFloat (modBy rows i) * cellW

        offSetY =
            rows - 1 - (toFloat i / toFloat rows |> floor) |> toFloat |> (*) cellH |> (+) cellH

        body_ =
            createEnvBody_ obj offSetX offSetY
                |> Body.toStatic

        result =
            Physic.addBody body_ physicsWorld
    in
    result


createEnvBody_ : Tiled.Object.Object -> Float -> Float -> Body comparable
createEnvBody_ obj offSetX offSetY =
    let
        getX x width =
            offSetX + x + width / 2

        getY y height =
            offSetY - height / 2 - y
    in
    case obj of
        Point { x, y } ->
            Body.rect (offSetX + x) (offSetY + y) 0 0

        Rectangle { x, y } { width, height } ->
            Body.rect (getX x width) (getY y height) width height

        Ellipse { x, y } { width, height } ->
            Body.ellipse (getX x width) (getY y height) width height

        Polygon { x, y } { width, height } polyPoints ->
            Body.rect (getX x width) (getY y height) width height

        PolyLine { x, y } { width, height } polyPoints ->
            Body.rect (getX x width) (getY y height) width height

        Tile { x, y } { width, height } gid ->
            Body.rect (getX x width) (getY y height) width height


createDynamicBody : { a | height : Float, width : Float, x : Float, y : Float } -> Tiled.Object.Object -> Maybe (Body comparable)
createDynamicBody { x, y, height, width } o =
    case o of
        Tiled.Object.Ellipse common dimension ->
            commonDimensionArgs common dimension
                |> (\o_ ->
                        Body.ellipse
                            (x - width / 2 + o_.width / 2 + o_.x)
                            (y + height / 2 - o_.y - o_.height / 2)
                            (o_.width / 2)
                            (o_.height / 2)
                   )
                |> Just

        Tiled.Object.Rectangle common dimension ->
            commonDimensionArgs common dimension
                |> (\o_ ->
                        Body.rect
                            (x - width / 2 + o_.width / 2 + o_.x)
                            (y + height / 2 - o_.y - o_.height / 2)
                            o_.width
                            o_.height
                   )
                |> Body.rotate (degrees common.rotation)
                |> Just

        _ ->
            Nothing


createEnvAABB i obj physicsWorld =
    let
        config =
            Physic.AABB.getConfig physicsWorld

        ( cellW, cellH ) =
            ( config.grid.cell.width, config.grid.cell.height )

        rows =
            abs (config.grid.boundary.ymax - config.grid.boundary.ymin) / cellH |> ceiling

        cols =
            abs (config.grid.boundary.xmax - config.grid.boundary.xmin) / cellW |> ceiling

        offSetX =
            toFloat (modBy cols i) * cellW

        offSetY =
            rows - 1 - (toFloat i / toFloat cols |> floor) |> toFloat |> (*) cellH |> (+) cellH

        body_ =
            createEnvAABB_ obj offSetX offSetY
                |> AABB.toStatic

        result =
            Physic.AABB.addBody body_ physicsWorld
    in
    result


createEnvAABB_ : Tiled.Object.Object -> Float -> Float -> AABB comparable
createEnvAABB_ obj offSetX offSetY =
    let
        getX x width =
            offSetX + x + width / 2

        getY y height =
            offSetY - height / 2 - y
    in
    case obj of
        Point { x, y } ->
            AABB.rect (offSetX + x) (offSetY + y) 0 0

        Rectangle { x, y } { width, height } ->
            AABB.rect (getX x width) (getY y height) width height

        Ellipse { x, y } { width, height } ->
            AABB.rect (getX x width) (getY y height) width height

        Polygon { x, y } { width, height } polyPoints ->
            AABB.rect (getX x width) (getY y height) width height

        PolyLine { x, y } { width, height } polyPoints ->
            AABB.rect (getX x width) (getY y height) width height

        Tile { x, y } { width, height } gid ->
            AABB.rect (getX x width) (getY y height) width height


createDynamicAABB : { a | height : Float, width : Float, x : Float, y : Float } -> Tiled.Object.Object -> Maybe (AABB comparable)
createDynamicAABB { x, y, height, width } o =
    case o of
        Tiled.Object.Ellipse common dimension ->
            commonDimensionArgs common dimension
                |> (\o_ ->
                        AABB.rect
                            (x - width / 2 + o_.width / 2 + o_.x)
                            (y + height / 2 - o_.y - o_.height / 2)
                            o_.width
                            o_.height
                   )
                |> Just

        Tiled.Object.Rectangle common dimension ->
            commonDimensionArgs common dimension
                |> (\o_ ->
                        AABB.rect
                            (x - width / 2 + o_.width / 2 + o_.x)
                            (y + height / 2 - o_.y - o_.height / 2)
                            o_.width
                            o_.height
                   )
                |> Just

        _ ->
            Nothing
