module Logic.Template.SaveLoad.Physics exposing (decode, encode, read)

import Bytes.Decode as D
import Bytes.Encode as E exposing (Encoder)
import Collision.Broad.Grid
import Collision.Physic.AABB
import Collision.Physic.Narrow.AABB as AABB exposing (AABB)
import Dict
import Logic.Component.Singleton as Singleton
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (extractObjectData)
import Tiled.Object exposing (Object(..))


encode : Singleton.Spec (Collision.Physic.AABB.World Int) world -> world -> Encoder
encode { get } world =
    let
        itemEncoder =
            AABB.toBytes (Maybe.map ((+) 1) >> Maybe.withDefault 0 >> E.id)

        indexedEncoder indexed =
            indexed
                |> Dict.toList
                |> E.list (\( id, item ) -> E.sequence [ E.id id, itemEncoder item ])

        static =
            get world
                |> .static
                |> Collision.Broad.Grid.toBytes itemEncoder
    in
    get world
        |> (\{ gravity, indexed } ->
                E.sequence
                    [ E.xy gravity
                    , indexedEncoder indexed
                    , static
                    ]
           )


decode : Singleton.Spec (Collision.Physic.AABB.World Int) world -> WorldDecoder world
decode spec_ =
    let
        itemIndex =
            D.id
                |> D.map
                    (\i ->
                        if i > 0 then
                            Just (i - 1)

                        else
                            Nothing
                    )

        itemDecoder =
            AABB.fromBytes itemIndex

        itemDecoderWith =
            AABB.fromBytes itemIndex |> D.map (\aabb_ -> ( AABB.boundary aabb_, aabb_ ))

        indexedDecoder =
            D.map2 Tuple.pair D.id itemDecoder
                |> D.list
                |> D.map Dict.fromList

        staticDecoder =
            Collision.Broad.Grid.fromBytes itemDecoderWith
    in
    D.map3
        (\gravity indexed static ->
            Singleton.update spec_
                (\a ->
                    { a | gravity = gravity, indexed = indexed, static = static }
                )
        )
        D.xy
        indexedDecoder
        staticDecoder


read : Singleton.Spec (Collision.Physic.AABB.World Int) world -> Reader world
read spec =
    let
        updateConfig f info =
            Collision.Physic.AABB.setConfig (f (Collision.Physic.AABB.getConfig info)) info

        clear =
            Collision.Physic.AABB.clear

        staticBody =
            createEnvAABB

        indexedBody =
            createDynamicAABB

        setIndex =
            AABB.withIndex

        addBody =
            Collision.Physic.AABB.addBody
    in
    { defaultRead
        | level =
            Sync
                (\level ( entityID, world ) ->
                    let
                        { tileheight, tilewidth, width, height } =
                            Util.common level

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
                                                setMass =
                                                    (Util.properties info |> .float) "mass"
                                                        |> Util.maybeDo AABB.setMass

                                                result =
                                                    addBody (setIndex mId body_ |> setMass) (spec.get world)
                                            in
                                            ( mId, spec.set result world )
                                        )
                                    |> Maybe.withDefault ( mId, world )
                            )
                )
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


createEnvAABB i obj physicsWorld =
    let
        config =
            Collision.Physic.AABB.getConfig physicsWorld

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
            Collision.Physic.AABB.addBody body_ physicsWorld
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

        Rectangle { x, y, width, height } ->
            AABB.rect (getX x width) (getY y height) width height

        Ellipse { x, y, width, height } ->
            AABB.rect (getX x width) (getY y height) width height

        Polygon { x, y, width, height } ->
            AABB.rect (getX x width) (getY y height) width height

        PolyLine { x, y, width, height } ->
            AABB.rect (getX x width) (getY y height) width height

        Tile { x, y, width, height } ->
            AABB.rect (getX x width) (getY y height) width height


createDynamicAABB : { a | height : Float, width : Float, x : Float, y : Float } -> Tiled.Object.Object -> Maybe (AABB comparable)
createDynamicAABB { x, y, height, width } o =
    case o of
        Tiled.Object.Point data ->
            AABB.rect x y 1 1 |> Just

        Tiled.Object.Ellipse data ->
            data
                |> (\o_ ->
                        AABB.rect
                            (x - width / 2 + o_.width / 2 + o_.x)
                            (y + height / 2 - o_.y - o_.height / 2)
                            o_.width
                            o_.height
                   )
                |> Just

        Tiled.Object.Rectangle data ->
            data
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
