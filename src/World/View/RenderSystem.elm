module World.View.RenderSystem exposing (debugPhysics, debugPhysicsAABB, viewSprite)

import AltMath.Vector2 as AVec2
import Layer.Common as Common
import Layer.Object.Animated
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.System as System exposing (System)
import Math.Vector2 as Vec2 exposing (vec2)
import Math.Vector3 exposing (vec3)
import Math.Vector4 exposing (vec4)
import Physic
import Physic.AABB
import Physic.Narrow.AABB
import Physic.Narrow.Body exposing (Body(..))
import World.Component.Sprite as ObjectComponent


debugPhysics common ( ecs, inLayer ) acc =
    ecs.physics
        |> Physic.toList
        |> List.map (Physic.Narrow.Body.debuInfo (fromPhysics common))
        |> (++) acc


debugPhysicsAABB common ( ecs, inLayer ) acc =
    ecs.physics
        |> Physic.AABB.toList
        |> List.map (Physic.Narrow.AABB.debuInfo (fromPhysics common))
        |> (++) acc


fromPhysics common =
    { circle =
        \p r ->
            { x = AVec2.getX p
            , y = AVec2.getY p
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
            { x = AVec2.getX p
            , y = AVec2.getY p
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
            { x = AVec2.getX p
            , y = AVec2.getY p
            , width = w
            , height = h
            , color = vec4 0 1 1 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.Layer common
                |> Layer.Object.Rectangle.render
    , radiusRectangle =
        \p r h ->
            { p = Vec2.fromRecord p
            , r = Vec2.fromRecord r
            , height = h
            , color = vec4 0 1 1 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.Layer common
                |> Layer.Object.Rectangle.render2
    }


viewSprite positions sprites getPosition common ( ecs, inLayer ) =
    System.foldl3 (render getPosition common) inLayer sprites positions


render getPosition common _ obj body acc =
    case obj of
        ObjectComponent.Sprite info ->
            let
                pos =
                    getPosition body
            in
            ({ info
                | x = pos.x |> round |> toFloat
                , y = pos.y |> round |> toFloat
             }
                |> Common.Layer common
                |> Layer.Object.Tile.render
            )
                :: acc

        ObjectComponent.Animated info ->
            let
                pos =
                    getPosition body
            in
            ({ info
                | x = pos.x |> round |> toFloat
                , y = pos.y |> round |> toFloat
             }
                |> Common.Layer common
                |> Layer.Object.Animated.render
            )
                :: acc
