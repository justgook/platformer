module Logic.Template.Layer.Object.Ellipse exposing (Model, draw)

import Defaults exposing (default)
import Logic.Template.Internal exposing (plate, tileVertexShader)
import Logic.Template.Layer exposing (LayerData(..), Uniform)
import Math.Vector2 exposing (Vec2)
import Math.Vector4 exposing (Vec4)
import WebGL exposing (Mesh, Shader)


type alias Model =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , color : Vec4
    }


draw : LayerData Model -> WebGL.Entity
draw (LayerData common individual) =
    { height = individual.height
    , width = individual.width
    , x = individual.x
    , y = individual.y
    , color = individual.color

    -- General
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio

    --    , pixelsPerUnit = common.pixelsPerUnit
    , px = common.px

    --    , viewportOffset = common.viewportOffset
    --    , aspectRatio = common.aspectRatio
    , time = common.time
    , viewport = common.viewport
    , offset = common.offset

    --    , absolute = common.absolute
    }
        |> WebGL.entityWith
            default.entitySettings
            tileVertexShader
            fragmentShader
            plate



-- http://glslsandbox.com/e#39889.0


fragmentShader : Shader a (Uniform Model) { uv : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec4 color;
        uniform float width;
        uniform float height;
        vec2 px = vec2( 1.0 / width, 1.0 / height );
        void main () {
            gl_FragColor = color;
            vec2 delme = uv * 2. - 1.;
            float result = dot(delme, delme);
            gl_FragColor.a = float(result < 1.0);
            gl_FragColor.a -= float(result < .85) * .75;
        }
    |]
