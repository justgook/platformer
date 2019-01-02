module Layer exposing (Layer(..), init, view)

import Defaults exposing (default)
import Dict exposing (Dict)
import Environment exposing (Environment)
import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Tiled.Layer
import Tiled.Level as Level exposing (Level)
import Tiled.Tileset exposing (Tileset)
import Tiled.Util
import WebGL
import WebGL.Texture exposing (Texture)
import World.Camera exposing (Camera)


type Layer
    = Tiles (Common.Individual Layer.Tiles.Model)
    | Image (Common.Individual Layer.Image.Model)


init : Level -> Dict String Texture -> List Layer
init level textures =
    let
        result =
            level
                |> Tiled.Util.layers
                |> List.concatMap
                    (\income ->
                        case income of
                            Tiled.Layer.Image layerData ->
                                Dict.get layerData.image textures
                                    |> Maybe.map
                                        (\t ->
                                            let
                                                props =
                                                    Tiled.Util.properties layerData
                                            in
                                            [ Image
                                                { image = t
                                                , transparentcolor = props.color "transparentcolor" default.transparentcolor
                                                , scrollRatio = scrollRatio (Dict.get "scrollRatio" layerData.properties == Nothing) props
                                                }
                                            ]
                                        )
                                    |> Maybe.withDefault []

                            Tiled.Layer.Object layerData ->
                                []

                            Tiled.Layer.Tile layerData ->
                                -- case Dict.get layerData.name lookUpTextures of
                                --     Just lut ->
                                --         let
                                --             _ =
                                --                 Debug.log "Parsing Tile layer" layerData
                                --             -- _ =
                                --             --     getTilesetsForLayer level layerData.data
                                --         in
                                --         [-- Tiles
                                --          -- { lut = lut
                                --          -- , lutSize = vec2 layerData.width layerData.height
                                --          -- , tileSet = Texture
                                --          -- , tileSetSize = Vec2
                                --          -- , tileSize = Vec2
                                --          -- , firstgid = Int
                                --          -- }
                                --         ]
                                --     Nothing ->
                                []

                            Tiled.Layer.InfiniteTile layerData ->
                                []
                    )
    in
    result


view : Environment -> Camera -> List Layer -> List WebGL.Entity
view env camera layers =
    let
        common =
            { pixelsPerUnit = camera.pixelsPerUnit
            , viewportOffset = camera.viewportOffset
            , widthRatio = env.widthRatio
            }

        result =
            layers
                |> List.concatMap
                    (\income ->
                        case income of
                            Tiles info ->
                                []

                            Image info ->
                                [ Common.Layer common info |> Layer.Image.render ]
                    )
    in
    result


scrollRatio : Bool -> Tiled.Util.PropertiesReader -> Vec2
scrollRatio dual props =
    if dual then
        vec2 (props.float "scrollRatio.x" default.scrollRatio) (props.float "scrollRatio.y" default.scrollRatio)

    else
        vec2 (props.float "scrollRatio" default.scrollRatio) (props.float "scrollRatio" default.scrollRatio)
