module World.RenderSystem exposing (debugCollision, debugPhysics, physicsObjectRender, preview)

import Layer.Common as Common
import Layer.Object.Animated
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (vec3)
import Math.Vector4 exposing (vec4)
import Physic.Body exposing (Body(..), debuInfo)
import Physics
import World.Component
import World.Component.Body
import World.Component.Object as ObjectComponent


debugPhysics common ( ecs, inLayer ) acc =
    let
        shapesDraw =
            ecs.physics
                |> Physics.toList
                |> List.map (debuInfo (fromPhysics common))

        --
        --        delme =
        --            { x = 24
        --            , y = 24
        --            , width = 10
        --            , height = 10
        --            , color = vec4 0 1 1 1
        --            , scrollRatio = vec2 1 1
        --            , transparentcolor = vec3 0 0 0
        --            }
        --                |> Common.Layer common
        --                |> Layer.Object.Rectangle.render
    in
    acc ++ shapesDraw


fromPhysics common =
    { circle =
        \p r ->
            { x = Vec2.getX p
            , y = Vec2.getY p
            , width = r * 2
            , height = r * 2
            , color = vec4 0 1 1 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.Layer common
                |> Layer.Object.Ellipse.render
    , ellipse =
        \p r r2 ->
            { x = Vec2.getX p
            , y = Vec2.getY p
            , width = r * 2
            , height = r2 * 2
            , color = vec4 0 1 1 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.Layer common
                |> Layer.Object.Ellipse.render
    , rectangle =
        \p w h ->
            { x = Vec2.getX p
            , y = Vec2.getY p
            , width = w
            , height = h
            , color = vec4 0 1 1 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.Layer common
                |> Layer.Object.Rectangle.render
    }


debugCollision common ( ecs, inLayer ) acc =
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


physicsObjectRender common ( ecs, inLayer ) =
    System.foldl3 (physicsObjectRender_ common)
        inLayer
        (World.Component.objects.spec.get ecs)
        (World.Component.Body.bodies.spec.get ecs)
        []


physicsObjectRender_ common _ obj body acc =
    case obj of
        ObjectComponent.Tile info ->
            ({ info | x = Vec2.getX (Physic.Body.getPosition body), y = Vec2.getY (Physic.Body.getPosition body) }
                |> Common.Layer common
                |> Layer.Object.Tile.render
            )
                :: acc

        ObjectComponent.Animated info ->
            ({ info | x = Vec2.getX (Physic.Body.getPosition body), y = Vec2.getY (Physic.Body.getPosition body) }
                |> Common.Layer common
                |> Layer.Object.Animated.render
            )
                :: acc

        ObjectComponent.Rectangle info ->
            ({ info | x = Vec2.getX (Physic.Body.getPosition body), y = Vec2.getY (Physic.Body.getPosition body) }
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
