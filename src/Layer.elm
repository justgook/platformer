module Layer exposing (Layer(..), init, view)

import Defaults exposing (default)
import Dict exposing (Dict)
import Environment exposing (Environment)
import Http
import Image exposing (Order(..))
import Image.BMP exposing (encodeWith)
import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import List.Extra as List
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Task exposing (Task)
import Tiled.Layer as Tiled
import Tiled.Level as Tiled exposing (Level)
import Tiled.Tileset as Tiled exposing (Tileset)
import Tiled.Util
import WebGL
import WebGL.Texture as WebGL exposing (Texture, linear, nearest, nonPowerOfTwoOptions)
import World.Camera exposing (Camera)


type Layer a
    = Tiles (Common.Individual Layer.Tiles.Model)
    | Image (Common.Individual Layer.Image.Model)
    | Object a


init : Level -> Task Http.Error (List (Layer a))
init level =
    let
        tilesets =
            Tiled.Util.tilesets level

        download im =
            "/assets/" ++ im |> WebGL.loadWith default.textureOption
    in
    level
        |> Tiled.Util.layers
        |> List.concatMap
            (\item ->
                case item of
                    Tiled.Image layerData ->
                        let
                            props =
                                Tiled.Util.properties layerData

                            result =
                                download layerData.image
                                    |> Task.map
                                        (\t ->
                                            Image
                                                { image = t
                                                , transparentcolor = props.color "transparentcolor" default.transparentcolor
                                                , scrollRatio = scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) props
                                                }
                                        )
                        in
                        [ result ]

                    Tiled.Tile layerData ->
                        Tiled.Util.splitTileLayerByTileSet layerData tilesets
                            |> tileLayerBuilder layerData

                    Tiled.InfiniteTile layerData ->
                        []

                    Tiled.Object layerData ->
                        -- let
                        --     _ =
                        --         Debug.log "start" layerData
                        -- in
                        []
            )
        |> Task.sequence
        |> Task.mapError (\_ -> Http.NetworkError)


view : Environment -> Camera -> List (Layer a) -> List WebGL.Entity
view env camera layers =
    let
        common =
            { pixelsPerUnit = camera.pixelsPerUnit
            , viewportOffset = camera.viewportOffset
            , widthRatio = env.widthRatio
            }
    in
    layers
        |> List.concatMap
            (\income ->
                case income of
                    Tiles info ->
                        [ Common.Layer common info |> Layer.Tiles.render ]

                    Image info ->
                        [ Common.Layer common info |> Layer.Image.render ]

                    Object info ->
                        let
                            _ =
                                Debug.log "Here goes" "Object layer"
                        in
                        []
            )


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
    { opt | order = RightDown }


tileLayerBuilder layerData =
    let
        download im =
            "/assets/" ++ im |> WebGL.loadWith default.textureOption
    in
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
                                |> andMap (encodeWith imageOptions layerData.width layerData.height data |> WebGL.loadWith default.textureOption)
                                |> andMap (download tileset.image)
                    in
                    [ result ]

                ( Tiled.Source _, _ ) ->
                    []

                ( Tiled.ImageCollection _, _ ) ->
                    []
        )


andMap : Task x a -> Task x (a -> b) -> Task x b
andMap =
    Task.map2 (|>)
