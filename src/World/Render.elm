module World.Render exposing (view)

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
import Layer.Object
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
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
import World.Model exposing (Model(..), World)


view : Environment -> Model -> List WebGL.Entity
view env (Model ({ camera, layers, frame } as world)) =
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
                        customSystem common ( world, info )
            )


customSystem :
    Common.Common
    -> ( World, Component.Set Layer.Object.Object )
    -> List WebGL.Entity
customSystem common ( world, infoSet ) =
    System.foldl2Custom
        (\( obj, seta ) ( b, setb ) acc ->
            case obj of
                Layer.Object.Rectangle info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                (info
                                    |> Common.Layer common
                                    |> Layer.Object.Rectangle.render
                                )
                            )

                Layer.Object.Ellipse info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                (info
                                    |> Common.Layer common
                                    |> Layer.Object.Ellipse.render
                                )
                            )

                Layer.Object.Tile info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                (info
                                    |> Common.Layer common
                                    |> Layer.Object.Tile.render
                                )
                            )

                _ ->
                    acc
        )
        (Component.second World.Component.objects)
        (Component.first World.Component.positions)
        ( ( world, infoSet ), [] )
        |> Tuple.second
