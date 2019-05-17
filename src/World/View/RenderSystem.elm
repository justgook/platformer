module World.View.RenderSystem exposing (debugPhysicsAABB, viewSprite)

import AltMath.Vector2 as AVec2
import Logic.System as System exposing (System)
import Logic.Template.Internal exposing (pxToScreen)
import Logic.Template.Layer as Common
import Logic.Template.Layer.Object.Ellipse as Ellipse
import Logic.Template.Layer.Object.Rectangle as Rectangle
import Logic.Template.SpriteComponent
import Math.Vector2 as Vec2 exposing (vec2)
import Math.Vector3 exposing (vec3)
import Math.Vector4 exposing (vec4)
import Physic.AABB
import Physic.Narrow.AABB


debugPhysicsAABB common ( ecs, _ ) acc =
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
                |> Common.LayerData common
                |> Ellipse.draw
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
                |> Common.LayerData common
                |> Ellipse.draw
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
                |> Common.LayerData common
                |> Rectangle.draw
    , radiusRectangle =
        \p_ r h ->
            let
                p =
                    pxToScreen common.px p_
            in
            { p = p
            , r = pxToScreen common.px r
            , height = h * common.px
            , color = vec4 0 1 1 1
            , scrollRatio = vec2 1 1
            , transparentcolor = vec3 0 0 0
            }
                |> Common.LayerData common
                |> Rectangle.render2
    }


viewSprite positions sprites getPosition ( esc, inLayer ) =
    System.foldl3
        (Logic.Template.SpriteComponent.draw esc.frame esc.render getPosition)
        inLayer
        sprites
        positions
