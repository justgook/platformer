module World exposing (World, init, view)

import Defaults exposing (default)
import Dict exposing (Dict)
import Environment exposing (Environment)
import Http
import Image.BMP exposing (encode24)
import Layer
import Task
import Tiled.Layer as Tiled
import Tiled.Level as Tiled
import Tiled.Tileset as Tiled
import Tiled.Util exposing (getListOfImages)
import WebGL
import WebGL.Texture as WebGL exposing (Texture, linear, nearest, nonPowerOfTwoOptions)
import World.Camera as Camera exposing (Camera)


type World
    = World
        { layers : List Layer.Layer
        , camera : Camera
        }


init : Tiled.Level -> Task.Task Http.Error World
init level =
    let
        imagesToDownload =
            addDownloadableImages level

        generatedImages =
            addLUTimages level
    in
    (imagesToDownload ++ generatedImages)
        --TODO make Download in parallel
        |> Task.sequence
        |> Task.mapError (\_ -> Http.NetworkError)
        |> Task.andThen
            (\tilesetImages ->
                let
                    -- lut =
                    --     lutImages
                    --         |> Dict.fromList
                    textures =
                        tilesetImages |> Dict.fromList
                in
                World
                    { layers = Layer.init level textures
                    , camera = Camera.init level
                    }
                    |> Task.succeed
            )


addDownloadableImages level =
    level
        |> getListOfImages
        |> List.map
            (\im ->
                "/assets/"
                    ++ im
                    |> loadTexture
                    |> Task.map (Tuple.pair im)
            )


addLUTimages level =
    Tiled.Util.layers level
        |> List.foldl
            (\item acc ->
                case item of
                    Tiled.Image info ->
                        []

                    Tiled.Object info ->
                        []

                    Tiled.Tile info ->
                        let
                            _ =
                                Tiled.Util.splitTileLayerByTileSet info (Tiled.Util.tilesets level)
                                    |> getListOfLUT
                        in
                        []

                    Tiled.InfiniteTile info ->
                        []
            )
            []


view : Environment -> World -> List WebGL.Entity
view env (World m) =
    Layer.view env m.camera m.layers


loadTexture url =
    WebGL.loadWith default.textureOption url


getListOfLUT =
    List.foldr
        (\i acc ->
            case i of
                ( Tiled.Embedded info, data ) ->
                    let
                        image =
                            encode24 info.imagewidth info.imageheight data

                        -- { lut : Texture
                        -- , lutSize : vec2 info.imagewidth info.imageheight
                        -- , tileSet : Texture
                        -- , tileSetSize : Vec2
                        -- , tileSize : Vec2
                        -- , pixelsPerUnit : Float
                        -- , viewportOffset : Vec2
                        -- , widthRatio : Float
                        -- }
                        -- a =
                        --     { columns = 4
                        --     , firstgid = 4
                        --     , image = "char1_test.png"
                        --     , imageheight = 120
                        --     , imagewidth = 64
                        --     , margin = 0
                        --     , name = "char1_test"
                        --     , properties = Dict.fromList []
                        --     , spacing = 0
                        --     , tilecount = 20
                        --     , tileheight = 24
                        --     , tiles = Dict.fromList []
                        --     , tilewidth = 16
                        --     , transparentcolor = "#ff00ff"
                        --     }
                        _ =
                            info |> Debug.log "getListOfLUT"
                    in
                    image :: acc

                ( Tiled.Source _, _ ) ->
                    acc

                ( Tiled.ImageCollection _, _ ) ->
                    acc
        )
        []
