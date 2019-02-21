module World.RenderSystem exposing (preview)

import Layer.Common as Common
import Layer.Object.Animated
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2)
import World.Component
import World.Component.Object as ObjectComponent


preview common ( ecs, inLayer ) =
    System.foldl3 (render common)
        inLayer
        (World.Component.objects.spec.get ecs)
        (World.Component.positions.spec.get ecs)
        []


render common _ obj pos acc =
    case obj of
        ObjectComponent.Tile info ->
            ({ info | x = Vec2.getX pos, y = Vec2.getY pos }
                |> Common.Layer common
                |> Layer.Object.Tile.render
            )
                :: acc

        ObjectComponent.Animated info ->
            ({ info | x = Vec2.getX pos, y = Vec2.getY pos }
                |> Common.Layer common
                |> Layer.Object.Animated.render
            )
                :: acc

        ObjectComponent.Rectangle info ->
            ({ info | x = Vec2.getX pos, y = Vec2.getY pos }
                |> Common.Layer common
                |> Layer.Object.Rectangle.render
            )
                :: acc

        ObjectComponent.Ellipse info ->
            (info
                |> Common.Layer common
                |> Layer.Object.Ellipse.render
            )
                :: acc
