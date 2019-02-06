module World.Render exposing (view)

-- import Layer.Object.Ellipse
-- import Layer.Object.Rectangle
-- import Layer.Object.Tile

import Array
import Defaults exposing (default)
import Dict exposing (Dict)
import Environment exposing (Environment)
import Http
import Image exposing (Order(..))
import Image.BMP exposing (encodeWith)
import Layer exposing (Layer(..))
import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Layer.Tiles.Animated
import List.Extra as List
import Logic.Component as Component
import Logic.System as System exposing (System, TupleSystem)
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
import World.Component


view objRender env ({ camera, layers, frame } as world) ecs =
    let
        common =
            { pixelsPerUnit = camera.pixelsPerUnit
            , viewportOffset = camera.viewportOffset
            , widthRatio = env.widthRatio
            , time = frame
            }
    in
    layers
        |> List.concatMap
            (\income ->
                case income of
                    Image info ->
                        [ Common.Layer common info |> Layer.Image.render ]

                    Tiles info ->
                        [ Common.Layer common info |> Layer.Tiles.render ]

                    AbimatedTiles info ->
                        [ Common.Layer common info |> Layer.Tiles.Animated.render ]

                    Object info ->
                        objRender common ( ecs, info )
            )
