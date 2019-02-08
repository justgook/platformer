module World.RenderSystem exposing (customSystem)

import Array exposing (Array)
import Ease exposing (Easing)
import Layer.Common as Common
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import List.Nonempty as NE exposing (Nonempty)
import Logic.Component as Component
import Logic.System as System exposing (System, andMap, end, start)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import World exposing (World(..))
import World.Component as Component


customSystem common ( ecs, infoSet ) =
    System.foldl2Custom
        (\( obj, seta ) ( pos, setb ) acc ->
            case obj of
                Component.Rectangle info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                ({ info | x = Vec2.getX pos, y = Vec2.getY pos }
                                    |> Common.Layer common
                                    |> Layer.Object.Rectangle.render
                                )
                            )

                Component.Ellipse info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                (info
                                    |> Common.Layer common
                                    |> Layer.Object.Ellipse.render
                                )
                            )

                Component.Tile info ->
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
        (Component.second Component.objects.spec)
        (Component.first Component.positions.spec)
        ( ( ecs, infoSet ), [] )
        |> Tuple.second
