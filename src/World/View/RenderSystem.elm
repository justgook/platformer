module World.View.RenderSystem exposing (debugPhysicsAABB, viewSprite)

import AltMath.Vector2 as AVec2
import Logic.System as System exposing (System)
import Logic.Template.Component.Sprite
import Logic.Template.Ellipse as Ellipse
import Logic.Template.Internal exposing (TileVertexShaderModel, pxToScreen, tileVertexShader)
import Logic.Template.Rectangle as Rectangle
import Math.Matrix4 exposing (Mat4)
import Math.Vector4 exposing (vec4)
import Physic.AABB
import Physic.Narrow.AABB
import WebGL


debugPhysicsAABB common ecs acc =
    ecs.physics
        |> Physic.AABB.toList
        |> List.map (Physic.Narrow.AABB.debuInfo (fromPhysics common))
        |> (++) acc


fromPhysics :
    { a | absolute : Mat4, px : Float }
    ->
        { circle : AVec2.Vec2 -> Float -> WebGL.Entity
        , ellipse : AVec2.Vec2 -> Float -> Float -> WebGL.Entity
        , radiusRectangle : AVec2.Vec2 -> AVec2.Vec2 -> Float -> WebGL.Entity
        , rectangle : AVec2.Vec2 -> Float -> Float -> WebGL.Entity
        }
fromPhysics renderInfo =
    { circle =
        \p r ->
            { height = r * 2
            , width = r * 2
            , absolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , color = vec4 0 1 1 1
            }
                |> Ellipse.draw tileVertexShader
    , ellipse =
        \p r r2 ->
            { height = r2 * 2
            , width = r * 2
            , absolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , color = vec4 0 1 1 1
            }
                |> Ellipse.draw tileVertexShader
    , rectangle =
        \p w h ->
            { height = h * renderInfo.px
            , width = w * renderInfo.px
            , absolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , color = vec4 0 1 1 1
            }
                |> Rectangle.draw tileVertexShader
    , radiusRectangle =
        \p r h ->
            let
                w =
                    r.x
            in
            { height = h * 2 * renderInfo.px
            , width = w * 2 * renderInfo.px
            , absolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , r = pxToScreen renderInfo.px r
            , px = renderInfo.px
            , color = vec4 0 1 1 1
            }
                |> Rectangle.draw2 tileVertexShader
    }


viewSprite positions sprites getPosition ( esc, inLayer ) =
    System.foldl3
        (Logic.Template.Component.Sprite.draw esc.frame esc.render getPosition)
        inLayer
        sprites
        positions
