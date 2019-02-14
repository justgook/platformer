module World.RenderSystem exposing (customSystem)

import Layer.Common as Common
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.Component as Component
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2)
import World.Component
import World.Component.Object as ObjectComponent


customSystem common ( ecs, infoSet ) =
    System.foldl2Custom
        (\( obj, _ ) ( pos, _ ) acc ->
            case obj of
                ObjectComponent.Rectangle info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                ({ info | x = Vec2.getX pos, y = Vec2.getY pos }
                                    |> Common.Layer common
                                    |> Layer.Object.Rectangle.render
                                )
                            )

                ObjectComponent.Ellipse info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                (info
                                    |> Common.Layer common
                                    |> Layer.Object.Ellipse.render
                                )
                            )

                ObjectComponent.Tile info ->
                    acc
                        |> Tuple.mapSecond
                            ((::)
                                (info
                                    |> Common.Layer common
                                    |> Layer.Object.Tile.render
                                )
                            )
        )
        (Component.second ObjectComponent.objects.spec)
        (Component.first World.Component.positions.spec)
        ( ( ecs, infoSet ), [] )
        |> Tuple.second
