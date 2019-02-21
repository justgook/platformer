module Layer.Image exposing (Model, render, renderNo, renderX, renderY)

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


renderX =
    render_ fragmentShaderRepeatX


renderY =
    render_ fragmentShaderRepeatY


renderNo =
    render_ fragmentShaderNoRepeat


render =
    render_ fragmentShaderRepeat


render_ : Shader {} (Uniform Model) { vcoord : Vec2 } -> Layer Model -> WebGL.Entity
render_ fragmentShader (Layer common individual) =
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


fragmentShaderRepeat : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShaderRepeat =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;

        uniform sampler2D image;
        uniform vec3 transparentcolor;
        uniform float pixelsPerUnit;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


fragmentShaderRepeatX : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShaderRepeatX =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;

        uniform sampler2D image;
        uniform vec3 transparentcolor;
        uniform float pixelsPerUnit;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.a *= float(pixel.y <= 1.0);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


fragmentShaderRepeatY : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShaderRepeatY =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;

        uniform sampler2D image;
        uniform vec3 transparentcolor;
        uniform float pixelsPerUnit;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.a *= float(pixel.x <= 1.0);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


fragmentShaderNoRepeat : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShaderNoRepeat =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;

        uniform sampler2D image;
        uniform vec3 transparentcolor;
        uniform float pixelsPerUnit;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.a *= float(pixel.x <= 1.0) * float(pixel.y <= 1.0);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]
