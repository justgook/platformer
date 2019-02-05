module Layer.Object.Ellipse exposing (Model, render)

import Defaults exposing (default)
import Layer.Common exposing (Layer(..), Uniform, mesh)
import Layer.Object.Common exposing (vertexShader)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector4 exposing (Vec4)
import WebGL exposing (Mesh, Shader)


type alias Model =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , color : Vec4
    }


render : Layer Model -> WebGL.Entity
render (Layer common individual) =
    { height = individual.height
    , width = individual.width
    , x = individual.x
    , y = individual.y
    , color = individual.color

    -- General
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , pixelsPerUnit = common.pixelsPerUnit
    , viewportOffset = common.viewportOffset
    , widthRatio = common.widthRatio
    , time = common.time
    }
        |> WebGL.entityWith
            default.entitySettings
            vertexShader
            fragmentShader
            mesh



-- http://glslsandbox.com/e#39889.0


fragmentShader : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform vec4 color;
        uniform float width;
        uniform float height;
        vec2 px = vec2( 1.0 / width, 1.0 / height );
        void main () {
            gl_FragColor = color;
            vec2 delme = vcoord * 2. - 1.;
            float result = dot(delme, delme);
            gl_FragColor.a = float(result < 1.0);
            gl_FragColor.a -= float(result < .85) * .75;
        }
    |]
