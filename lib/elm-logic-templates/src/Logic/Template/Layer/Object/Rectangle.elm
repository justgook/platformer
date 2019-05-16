module Logic.Template.Layer.Object.Rectangle exposing (Model, draw, render2)

import Defaults exposing (default)
import Logic.Template.Internal exposing (plate, tileVertexShader)
import Logic.Template.Layer exposing (LayerData(..), Uniform)
import Math.Matrix4 exposing (Mat4)
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


fragmentShader : Shader a (Uniform Model) { uv : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec4 color;
        uniform float width;
        uniform float height;
        float widthPx =  0.5 / width;
        float heightPx =  0.5 / height ;
        void main () {
            gl_FragColor = color;
            if (uv.x < 1.0 - widthPx
                && uv.x > widthPx
                && uv.y < 1.0 - heightPx
                && uv.y > heightPx
                ) {
                 gl_FragColor.a = 0.25;
            }
        }
    |]


type alias Model2 =
    { p : Vec2
    , r : Vec2
    , height : Float
    , color : Vec4
    }


render2 : LayerData Model2 -> WebGL.Entity
render2 (LayerData common individual) =
    { height = individual.height
    , r = individual.r
    , p = individual.p
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
            vertexShaderForFragmentRotation
            fragmentShader2
            plate


fragmentShader2 : Shader a (Uniform Model2) { uv : Vec2 }
fragmentShader2 =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec4 color;
        uniform float height;
        uniform float px;
        uniform vec2 p;
        uniform vec2 r;
//--https://thebookofshaders.com/08/
        float width = length(r);
        float widthPx =  0.5 / (width / px);
        float heightPx =  0.5 / (height / px) ;
        mat2 scale(vec2 _scale){
            return mat2(_scale.x,0.0,
                        0.0,_scale.y);
        }

        mat2 rotate2d(vec2 r_){
            float _angle = atan(r_.y/r_.x);
            return mat2(cos(_angle),-sin(_angle),
                        sin(_angle),cos(_angle));
        }

        void main () {
          float maxed = sqrt(width * width + height * height);
          vec2 uv_ = uv;
            uv_ -= vec2(0.5);


            uv_ = rotate2d(r) * uv_;

            uv_ = scale( vec2 (maxed / width, maxed / height)) * uv_;

            uv_ += vec2(0.5);
          gl_FragColor = color;
          if (uv_.x < 1.0 - widthPx
              && uv_.x > widthPx
              && uv_.y < 1.0 - heightPx
              && uv_.y > heightPx
              ) {
               gl_FragColor.a = 0.25;
          }
          if(uv_.x > 1. || uv_.y > 1. || uv_.x < 0. || uv_.y < 0. )
            gl_FragColor.a = 0.;
        }

    |]



--https://thebookofshaders.com/08/


vertexShaderForFragmentRotation :
    Shader
        { a
            | position : Vec2
        }
        { b
            | height : Float
            , r : Vec2
            , viewport : Mat4
            , px : Float

            --            , pixelsPerUnit : Float
            --                        , scrollRatio : Vec2
            , offset : Vec2

            --            , aspectRatio : Float
            , p : Vec2
        }
        { uv : Vec2 }
vertexShaderForFragmentRotation =
    [glsl| precision mediump float;
    attribute vec2 position;
    uniform vec2 p;
    uniform vec2 r;
    uniform float height;
    uniform mat4 viewport;
    uniform float px;
    uniform vec2 offset;
    varying vec2 uv;

    float width = length(r);
    void main () {
        uv = position;
        float maxed = sqrt(width * width + height * height);
        vec2 sized = vec2(position * vec2(maxed * 2., maxed * 2.));
        vec2 move = vec2(
           (p.x - offset.x - maxed ),
           (p.y - offset.y - maxed )
        );
        gl_Position =  viewport * vec4(sized + move, 0, 1.0);
    }

    |]
