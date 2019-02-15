module World.Create2 exposing (init)

import Defaults exposing (default)
import Dict exposing (Dict)
import Layer
import Math.Vector2 exposing (Vec2, vec2)
import ResourceTask exposing (ResourceTask)
import Tiled.Layer
import Tiled.Tileset
import Tiled.Util exposing (common)
import Tiled.Util2
import WebGL.Texture
import World.Camera as Camera
import World.Component.ImageLayer exposing (imageLayer)
import World.Component.TileLayer exposing (tileLayer)


init level start =
    let
        camera =
            Camera.init level

        --
        --        levelHeight =
        --            Tiled.Util.common level |> (\{ height, tileheight } -> tileheight * height |> toFloat)
        begin : ResourceTask ( List a, List Tiled.Tileset.Tileset )
        begin =
            ResourceTask.succeedWithCache ( [], Tiled.Util2.tilesets level ) start

        layersTask =
            (common level).layers
                |> List.foldr
                    (\layer ->
                        case layer of
                            Tiled.Layer.Image imageData ->
                                ResourceTask.andThenWithCache
                                    (\( acc, tilesets ) ->
                                        imageLayer imageData
                                            >> ResourceTask.map (\x -> ( x :: acc, tilesets ))
                                    )

                            Tiled.Layer.Tile tileData ->
                                ResourceTask.andThenWithCache
                                    (\( acc, tilesets ) ->
                                        tileLayer tilesets tileData
                                            >> ResourceTask.map (Tuple.mapFirst (\xs -> xs ++ acc))
                                    )

                            Tiled.Layer.Object objectData ->
                                ResourceTask.andThenWithCache
                                    (\( acc, tileset ) ->
                                        ResourceTask.succeedWithCache ( acc, tileset )
                                    )

                            Tiled.Layer.InfiniteTile tileChunkedData ->
                                ResourceTask.andThenWithCache
                                    (\( acc, tileset ) ->
                                        ResourceTask.succeedWithCache ( acc, tileset )
                                    )
                    )
                    begin
    in
    ResourceTask.map Tuple.first layersTask
