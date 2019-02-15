module World.Create exposing (GetImageData, init)

-- import Dict.Any as Dict

import Array exposing (Array)
import Defaults exposing (default)
import Dict
import Error exposing (Error)
import Http
import Image exposing (Order(..))
import Image.BMP exposing (encodeWith)
import Layer exposing (Layer(..))
import Logic.Entity as Entity
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Task exposing (Task)
import Tiled
import Tiled.Layer as Tiled
import Tiled.Object
import Tiled.Tileset as Tiled exposing (Tileset)
import Tiled.Util
import WebGL.Texture as WebGL
import World
import World.Camera as Camera exposing (Camera)


download im =
    "/assets/" ++ im |> WebGL.loadWith default.textureOption


type alias GetImageData =
    Int -> Maybe Tileset


getImageData : List Tileset -> GetImageData
getImageData t gid =
    let
        info =
            Tiled.gidInfo gid
    in
    info
        |> .gid
        |> Tiled.Util.tilesetById3 t


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
            (\item ( layerListOfTask, id, worldSpawnTask ) ->
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
                        ( layerListOfTask ++ [ result ], id, worldSpawnTask )

                    Tiled.Tile layerData ->
                        let
                            { static, animated } =
                                Tiled.Util.splitTileLayerByTileSet layerData tilesets

                            staticLayersTasks =
                                tileStaticLayerBuilder layerData static

                            animatedLayersTasks =
                                tileAnimatedLayerBuilder layerData animated
                        in
                        ( layerListOfTask ++ staticLayersTasks ++ animatedLayersTasks, id, worldSpawnTask )

                    Tiled.InfiniteTile _ ->
                        ( layerListOfTask, id, worldSpawnTask )

                    Tiled.Object layerData ->
                        let
                            ( newId, newWorldSpawn ) =
                                List.foldr
                                    (\obj acc_ ->
                                        case obj of
                                            Tiled.Object.Point common ->
                                                objectSpawn_ (\{ objectPoint } -> objectPoint common) acc_

                                            Tiled.Object.Rectangle common dimension ->
                                                objectSpawn_ (\{ objectRectangle } -> objectRectangle common dimension) acc_

                                            Tiled.Object.Ellipse common dimension ->
                                                objectSpawn_ (\{ objectEllipse } -> objectEllipse common dimension) acc_

                                            Tiled.Object.Polygon common dimension polyPoints ->
                                                objectSpawn_ (\{ objectPolygon } -> objectPolygon common dimension polyPoints) acc_

                                            Tiled.Object.PolyLine common dimension polyPoints ->
                                                objectSpawn_ (\{ objectPolyLine } -> objectPolyLine common dimension polyPoints) acc_

                                            Tiled.Object.Tile common dimension gid ->
                                                let
                                                    common2 =
                                                        { common | y = levelHeight - common.y + dimension.height / 2, x = common.x + dimension.width / 2 }
                                                in
                                                objectSpawn_
                                                    (\{ objectTile } -> objectTile (getImageData tilesets) common2 dimension gid)
                                                    acc_
                                    )
                                    ( id, worldSpawnTask )
                                    layerData.objects
                        in
                        ( layerListOfTask, newId, newWorldSpawn )
            )
            ( [], -1, Task.succeed )
        |> (\( layerListOfTask, id, func ) ->
                Task.sequence layerListOfTask
                    |> Task.mapError (\_ -> Http.NetworkError)
                    |> Task.andThen
                        (\layers ->
                            empty camera layers
                                |> (\(World.World a b) ->
                                        func b
                                            |> Task.map (Debug.log "RESULT WOLD AFTER CREATE")
                                            |> Task.mapError (\_ -> Http.NetworkError)
                                            |> Task.map (\w -> World.World a w)
                                   )
                        )
           )


objectSpawn read f1 ( id_, spawnTask ) =
    let
        newId_ =
            id_ + 1

        newAcc =
            List.foldl
                (\r escF ->
                    escF >> Task.andThen (Entity.create newId_ >> f1 r >> Task.map Tuple.second)
                )
                spawnTask
                read
    in
    ( newId_, newAcc )


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
