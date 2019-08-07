module Logic.Template.Ellipse exposing (Model, draw)

import Logic.Template.Internal exposing (Plate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector4 exposing (Vec4)
import WebGL exposing (Mesh, Shader)


type alias Model a =
    { a
        | uDimension : Vec2
        , color : Vec4
    }


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader
        plate



-- http://glslsandbox.com/e#39889.0


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec4 color;
        uniform vec2 uDimension;
        float width = uDimension.x;
        float height = uDimension.y;
        vec2 px = vec2( 1.0 / width, 1.0 / height );
        void main () {
            gl_FragColor = color;
            vec2 delme = uv * 2. - 1.;
            float result = dot(delme, delme);
            gl_FragColor.a = float(result < 1.0);
            gl_FragColor.a -= float(result < .85) * .75;
        }
    |]
