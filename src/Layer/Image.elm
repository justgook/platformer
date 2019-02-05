module Layer.Image exposing (Model, render)

import Defaults exposing (default)
import Layer.Common exposing (Layer(..), Uniform, mesh, vertexShader)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend
import WebGL.Texture exposing (Texture)


type alias Model =
    { image : Texture
    , size : Vec2
    }


render : Layer Model -> WebGL.Entity
render (Layer common individual) =
    -- let
    --     _ =
    --         Debug.log "pixelsPerUnit" common.pixelsPerUnit
    -- in
    { pixelsPerUnit = common.pixelsPerUnit
    , viewportOffset = common.viewportOffset
    , widthRatio = common.widthRatio
    , time = common.time
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , image = individual.image
    , size = individual.size
    }
        |> WebGL.entityWith
            default.entitySettings
            vertexShader
            fragmentShader
            mesh


fragmentShader : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;

        uniform sampler2D image;
        uniform vec3 transparentcolor;
        uniform float pixelsPerUnit;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform vec2 size;
        float px = 1.0 / pixelsPerUnit;

        void main () {
            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(vcoord * pixelsPerUnit) + 0.5) / size;
            gl_FragColor = texture2D(image, mod(pixel + viewportOffset * px * scrollRatio, 1.0));
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]
