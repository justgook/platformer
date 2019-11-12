module Logic.Template.Game.Platformer.RenderSystem exposing (debugPhysicsAABB)

import AltMath.Vector2 as AVec2 exposing (Vec2)
import Collision.Physic.AABB
import Collision.Physic.Narrow.AABB
import Logic.Template.Ellipse as Ellipse
import Logic.Template.Internal exposing (TileVertexShaderModel, tileVertexShader)
import Logic.Template.Rectangle as Rectangle
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vector2 exposing (vec2)
import Math.Vector4 exposing (vec4)
import WebGL


debugPhysicsAABB common ecs acc =
    ecs.physics
        |> Collision.Physic.AABB.toList
        |> List.map (Collision.Physic.Narrow.AABB.debuInfo (fromPhysics common))
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
    let
        pxToScreen : Float -> Vec2 -> Vector2.Vec2
        pxToScreen px p =
            AVec2.scale px p
                |> AVec2.toRecord
                |> Vector2.fromRecord
    in
    { circle =
        \p r ->
            { height = r * 2
            , width = r * 2
            , uDimension = vec2 (r * 2) (r * 2)
            , absolute = renderInfo.absolute
            , uAbsolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , uP = pxToScreen renderInfo.px p
            , color = vec4 0 1 1 1
            }
                |> Ellipse.draw tileVertexShader
    , ellipse =
        \p r r2 ->
            { height = r2 * 2
            , width = r * 2
            , uDimension = vec2 (r * 2) (r2 * 2)
            , absolute = renderInfo.absolute
            , uAbsolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , uP = pxToScreen renderInfo.px p
            , color = vec4 0 1 1 1
            }
                |> Ellipse.draw tileVertexShader
    , rectangle =
        \p w h ->
            { height = h * renderInfo.px
            , width = w * renderInfo.px
            , uDimension = vec2 (w * renderInfo.px) (h * renderInfo.px)
            , absolute = renderInfo.absolute
            , uAbsolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , uP = pxToScreen renderInfo.px p
            , color = vec4 0 1 1 1
            }
                |> Rectangle.draw tileVertexShader
    , radiusRectangle =
        \p r h ->
            let
                w =
                    AVec2.getX r
            in
            { height = h * 2 * renderInfo.px
            , width = w * 2 * renderInfo.px
            , uDimension = vec2 (w * 2 * renderInfo.px) (h * 2 * renderInfo.px)
            , absolute = renderInfo.absolute
            , uAbsolute = renderInfo.absolute
            , p = pxToScreen renderInfo.px p
            , uP = pxToScreen renderInfo.px p
            , r = pxToScreen renderInfo.px r
            , px = renderInfo.px
            , color = vec4 0 1 1 1
            }
                |> Rectangle.draw2 tileVertexShader
    }
