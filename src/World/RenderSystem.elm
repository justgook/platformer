module World.RenderSystem exposing (debugQadtree, preview)

import Broad.QuadTree
import Layer.Common as Common
import Layer.Object.Animated
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (vec3)
import Math.Vector4 exposing (vec4)
import World.Component
import World.Component.Object as ObjectComponent


debugQadtree common ( ecs, inLayer ) acc =
    let
        fn =
            Common.Layer common
                >> Layer.Object.Rectangle.render

        fn2 ( x, y ) =
            { x = x
            , y = y
            , width = 10
            , height = 10
            , color = vec4 0 1 0 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.Layer common
                |> Layer.Object.Ellipse.render

        points =
            Broad.QuadTree.drawPoints fn2 ecs.collisions
    in
    points
        |> (++) (Broad.QuadTree.debug fn ecs.collisions)
        |> (++)
            acc


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
