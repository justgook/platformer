module World.Create exposing (init)

-- import Dict.Any as Dict

import Array exposing (Array)
import Defaults exposing (default)
import Dict
import Http
import Image exposing (Order(..))
import Image.BMP exposing (encodeWith)
import Layer exposing (Layer(..))
import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import List.Extra as List
import Logic.Component as Component
import Logic.Entity as Entity
import Logic.GameFlow as Flow
import Logic.System as System
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Math.Vector4 exposing (Vec4, vec4)
import Task exposing (Task)
import Tiled
import Tiled.Layer as Tiled
import Tiled.Level as Tiled exposing (Level)
import Tiled.Object
import Tiled.Tileset as Tiled
import Tiled.Util
import WebGL
import WebGL.Texture as WebGL exposing (linear, nearest)
import World
import World.Camera as Camera exposing (Camera)
import World.Component as Component


download im =
    "/assets/" ++ im |> WebGL.loadWith default.textureOption


init read empty level =
    let
        objectSpawn_ =
            objectSpawn read

        tilesets =
            Tiled.Util.tilesets level

        camera =
            Camera.init level

        levelHeight =
            Tiled.Util.common level |> (\{ height, tileheight } -> tileheight * height |> toFloat)
    in
    level
        |> Tiled.Util.layers
        |> List.foldl
            (\item ( acc, id, worldSpawn ) ->
                case item of
                    Tiled.Image layerData ->
                        let
                            props =
                                Tiled.Util.properties layerData

                            result =
                                download layerData.image
                                    |> Task.map
                                        (\t ->
                                            let
                                                ( width, height ) =
                                                    WebGL.size t
                                            in
                                            Image
                                                { image = t
                                                , size = vec2 (toFloat width) (toFloat height)
                                                , transparentcolor = props.color "transparentcolor" default.transparentcolor
                                                , scrollRatio = scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) props
                                                }
                                        )
                        in
                        ( acc ++ [ result ], id, worldSpawn )

                    Tiled.Tile layerData ->
                        let
                            { static, animated } =
                                Tiled.Util.splitTileLayerByTileSet layerData tilesets

                            staticLayersTasks =
                                tileStaticLayerBuilder layerData static

                            animatedLayersTasks =
                                tileAnimatedLayerBuilder layerData animated
                        in
                        ( acc ++ staticLayersTasks ++ animatedLayersTasks, id, worldSpawn )

                    Tiled.InfiniteTile layerData ->
                        ( acc, id, worldSpawn )

                    Tiled.Object layerData ->
                        let
                            ( newId, ( newWorldSpawn, newWorldSpawn2 ) ) =
                                List.foldr
                                    (\obj ->
                                        case obj of
                                            Tiled.Object.Point common ->
                                                objectSpawn_ (\{ objectPoint } -> objectPoint common)

                                            Tiled.Object.Rectangle common dimension ->
                                                objectSpawn_ (\{ objectRectangle } -> objectRectangle common dimension)

                                            Tiled.Object.Ellipse common dimension ->
                                                objectSpawn_ (\{ objectEllipse } -> objectEllipse common dimension)

                                            Tiled.Object.Polygon common dimension polyPoints ->
                                                objectSpawn_ (\{ objectPolygon } -> objectPolygon common dimension polyPoints)

                                            Tiled.Object.PolyLine common dimension polyPoints ->
                                                objectSpawn_ (\{ objectPolyLine } -> objectPolyLine common dimension polyPoints)

                                            Tiled.Object.Tile common dimension gid ->
                                                objectSpawn_ (\{ objectTile } -> objectTile { common | y = levelHeight - common.y } dimension gid)
                                    )
                                    ( id, ( worldSpawn, identity ) )
                                    layerData.objects

                            objLayer =
                                newWorldSpawn2 Array.empty
                                    |> Object
                                    |> Task.succeed
                        in
                        ( acc ++ [ objLayer ], newId, newWorldSpawn )
             -- let
             --     ( newAcc, newId, newWorldSpawn ) =
             --         List.foldl (spwnObjects levelHeight layerData tilesets) ( Task.succeed Array.empty, id, worldSpawn ) layerData.objects
             -- in
             -- ( acc ++ [ newAcc |> Task.map Object ], newId, newWorldSpawn )
            )
            ( [], -1, identity )
        |> (\( taskList, id, func ) ->
                taskList
                    |> Task.sequence
                    |> Task.mapError (\_ -> Http.NetworkError)
                    |> Task.map
                        (\layers ->
                            empty camera layers
                                |> (\(World.World a b) -> World.World a (func b))
                        )
           )


objectSpawn read f1 ( id_, ( acc1, acc2 ) ) =
    let
        newId_ =
            id_ + 1

        readFolder f_ read_ entAcc =
            List.foldl f_ entAcc read_

        ( newAcc1, newAcc2 ) =
            readFolder f1 read ( acc1 >> Entity.create newId_, acc2 >> Entity.create newId_ )
    in
    ( newId_, ( newAcc1 >> Tuple.second, newAcc2 >> Tuple.second ) )



-- ( newId_, ( acc1, acc2 ) )
-- spwnObjects levelHeight layerData tilesets obj ( acc, id, worldSpawn ) =
--     let
--         newId =
--             id + 1
--         newSpawn =
--             worldSpawn
--                 >> Entity.create newId
--                 >> Entity.with ( Component.positions, vec2 21 21 )
--                 >> Entity.with ( Component.dimensions, vec2 22 22 )
--                 >> Entity.with ( Component.velocities, vec2 23 23 )
--                 >> Entity.with ( Component.animations, vec2 24 24 )
--                 >> Entity.with ( Component.delme, vec3 25 25 25 )
--                 >> Tuple.second
--         newAcc =
--             Task.map2
--                 (\obj_ acc_ ->
--                     acc_
--                         |> Entity.create newId
--                         |> Entity.with ( Component.objects, obj_ )
--                         |> Tuple.second
--                 )
--                 (objectRenderInfo levelHeight layerData tilesets obj)
--                 acc
--     in
--     ( newAcc, newId, newSpawn )
-- objectRenderInfo levelHeight layerData tilesets object =
--     let
--         layerProps =
--             Tiled.Util.properties layerData
--         layerScrollRatio =
--             scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps
--     in
--     case object of
--         Tiled.Object.Tile common dimension gid ->
--             let
--                 gidInfo =
--                     Tiled.gidInfo gid
--             in
--             case Tiled.Util.tilesetById tilesets gidInfo.gid of
--                 Just (Tiled.Embedded tileset) ->
--                     Task.map
--                         (\tilesetImage ->
--                             let
--                                 tilsetProps =
--                                     Tiled.Util.properties tileset
--                             in
--                             Layer.Object.Tile
--                                 { x = common.x + dimension.width / 2
--                                 , y = levelHeight - common.y + dimension.height / 2
--                                 , width = dimension.width
--                                 , height = dimension.height
--                                 , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
--                                 , scrollRatio = layerScrollRatio
--                                 , mirror = vec2 (boolToFloat gidInfo.fh) (boolToFloat gidInfo.fv)
--                                 -- First element alway should be 1, 0 is for empty
--                                 , tileIndex = gidInfo.gid - tileset.firstgid + 1 |> toFloat
--                                 , tileSet = tilesetImage
--                                 , tileSetSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
--                                 , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
--                                 }
--                         )
--                         (download tileset.image)
--                 _ ->
--                     Layer.Object.Rectangle
--                         { x = common.x + dimension.width / 2
--                         , y = levelHeight - common.y + dimension.height / 2
--                         , width = dimension.width
--                         , height = dimension.height
--                         , color = vec4 1 0 1 1
--                         , scrollRatio = layerScrollRatio
--                         , transparentcolor = default.transparentcolor
--                         }
--                         |> Task.succeed
--         Tiled.Object.Rectangle common dimension ->
--             Layer.Object.Rectangle
--                 { x = common.x + dimension.width / 2
--                 , y = levelHeight - common.y - dimension.height / 2
--                 , width = dimension.width
--                 , height = dimension.height
--                 , color = vec4 1 1 0 1
--                 , scrollRatio = layerScrollRatio
--                 , transparentcolor = default.transparentcolor
--                 }
--                 |> Task.succeed
--         Tiled.Object.Ellipse common dimension ->
--             Layer.Object.Ellipse
--                 { x = common.x + dimension.width / 2
--                 , y = levelHeight - common.y - dimension.height / 2
--                 , width = dimension.width
--                 , height = dimension.height
--                 , color = vec4 0 1 0 1
--                 , scrollRatio = layerScrollRatio
--                 , transparentcolor = default.transparentcolor
--                 }
--                 |> Task.succeed
--         _ ->
--             Layer.Object.Rectangle
--                 { x = 10 + toFloat 5
--                 , y = 10 + toFloat 5
--                 , width = 20
--                 , height = 20
--                 , color = vec4 1 1 1 1
--                 , scrollRatio = layerScrollRatio
--                 , transparentcolor = default.transparentcolor
--                 }
--                 |> Task.succeed


scrollRatio : Bool -> Tiled.Util.PropertiesReader -> Vec2
scrollRatio dual props =
    if dual then
        vec2 (props.float "scrollRatio.x" default.scrollRatio) (props.float "scrollRatio.y" default.scrollRatio)

    else
        vec2 (props.float "scrollRatio" default.scrollRatio) (props.float "scrollRatio" default.scrollRatio)


imageOptions =
    let
        opt =
            Image.defaultOptions
    in
    { opt | order = LeftUp }


tileStaticLayerBuilder layerData =
    List.concatMap
        (\i ->
            case i of
                ( Tiled.Embedded tileset, data ) ->
                    let
                        layerProps =
                            Tiled.Util.properties layerData

                        tilsetProps =
                            Tiled.Util.properties tileset

                        result =
                            Task.succeed
                                (\lut tileSetImage ->
                                    Tiles
                                        { lut = lut
                                        , lutSize = vec2 (toFloat layerData.width) (toFloat layerData.height)
                                        , tileSet = tileSetImage
                                        , tileSetSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
                                        , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                                        , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
                                        , scrollRatio = scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps
                                        }
                                )
                                |> andMapTask (encodeWith imageOptions layerData.width layerData.height data |> WebGL.loadWith default.textureOption)
                                |> andMapTask (download tileset.image)
                    in
                    [ result ]

                ( Tiled.Source _, _ ) ->
                    []

                ( Tiled.ImageCollection _, _ ) ->
                    []
        )


tileAnimatedLayerBuilder layerData =
    List.concatMap
        (\i ->
            case i of
                ( ( Tiled.Embedded tileset, anim ), data ) ->
                    let
                        layerProps =
                            Tiled.Util.properties layerData

                        tilsetProps =
                            Tiled.Util.properties tileset

                        animLutData =
                            animationFraming anim

                        animLength =
                            List.length animLutData

                        result =
                            Task.succeed
                                (\tileSetImage lut animLUT ->
                                    AbimatedTiles
                                        { lut = lut
                                        , lutSize = vec2 (toFloat layerData.width) (toFloat layerData.height)
                                        , tileSet = tileSetImage
                                        , tileSetSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)
                                        , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                                        , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
                                        , scrollRatio = scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) layerProps
                                        , animLUT = animLUT
                                        , animLength = animLength
                                        }
                                )
                                |> andMapTask (download tileset.image)
                                |> andMapTask
                                    (encodeWith imageOptions layerData.width layerData.height data
                                        |> WebGL.loadWith default.textureOption
                                    )
                                |> andMapTask
                                    (encodeWith imageOptions animLength 1 animLutData
                                        |> WebGL.loadWith default.textureOption
                                    )
                    in
                    [ result ]

                ( ( Tiled.Source _, _ ), _ ) ->
                    []

                ( ( Tiled.ImageCollection _, _ ), _ ) ->
                    []
        )


animationFraming anim =
    anim
        |> List.concatMap
            (\{ duration, tileid } ->
                List.repeat (toFloat duration / 1000 * default.fps |> floor) tileid
            )


andMapTask : Task x a -> Task x (a -> b) -> Task x b
andMapTask =
    Task.map2 (|>)


boolToFloat : Bool -> Float
boolToFloat b =
    if b then
        1

    else
        0
