module Layer.Object.Rectangle exposing (Model, render, render2)

import Defaults exposing (default)
import Layer.Common exposing (Layer(..), Uniform, mesh)
import Layer.Object.Common exposing (vertexShader)
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


fragmentShader : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform vec4 color;
        uniform float width;
        uniform float height;
        float widthPx =  0.5 / width;
        float heightPx =  0.5 / height ;
        void main () {
            gl_FragColor = color;
            if (vcoord.x < 1.0 - widthPx
                && vcoord.x > widthPx
                && vcoord.y < 1.0 - heightPx
                && vcoord.y > heightPx
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


render2 : Layer Model2 -> WebGL.Entity
render2 (Layer common individual) =
    { height = individual.height
    , r = individual.r
    , p = individual.p
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
            vertexShaderForFragmentRotation
            fragmentShader2
            mesh


fragmentShader2 : Shader a (Uniform Model2) { vcoord : Vec2 }
fragmentShader2 =
    [glsl|
        precision mediump float;
//        #define PI
        varying vec2 vcoord;
        uniform vec4 color;
        uniform float height;
        uniform vec2 p;
        uniform vec2 r;
//--https://thebookofshaders.com/08/
        float width = length(r);
        float widthPx =  0.5 / width;
        float heightPx =  0.5 / height ;
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
          vec2 vcoord_ = vcoord;
            vcoord_ -= vec2(0.5);


            vcoord_ = rotate2d(r) * vcoord_;

            vcoord_ = scale( vec2 (maxed / width, maxed / height)) * vcoord_;

            vcoord_ += vec2(0.5);
          gl_FragColor = color;
          if (vcoord_.x < 1.0 - widthPx
              && vcoord_.x > widthPx
              && vcoord_.y < 1.0 - heightPx
              && vcoord_.y > heightPx
              ) {
               gl_FragColor.a = 0.25;
          }
          if(vcoord_.x > 1. || vcoord_.y > 1. || vcoord_.x < 0. || vcoord_.y < 0. )
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
            , pixelsPerUnit : Float
            , scrollRatio : Vec2
            , viewportOffset : Vec2
            , widthRatio : Float
            , p : Vec2
        }
        { vcoord : Vec2 }
vertexShaderForFragmentRotation =
    [glsl| precision mediump float;
    attribute vec2 position;

    uniform vec2 p;
    uniform vec2 r;
    uniform float height;
    uniform float widthRatio;
    uniform float pixelsPerUnit;
    uniform vec2 viewportOffset;
    uniform vec2 scrollRatio;
    varying vec2 vcoord;

    float px = 1.0 / pixelsPerUnit;
    //const float PI = 3.1415926535897932384626433832795;

    //https://gist.github.com/patriciogonzalezvivo/986341af1560138dde52
    mat4 translate(float x, float y, float z) {
       return mat4(
           vec4(1.0, 0.0, 0.0, 0.0),
           vec4(0.0, 1.0, 0.0, 0.0),
           vec4(0.0, 0.0, 1.0, 0.0),
           vec4(x,   y,   z,   1.0)
       );
    }
//    mat4 RotateZ(float psi){
//       return mat4(
//           cos(psi),-sin(psi),0.,0,
//           sin(psi),cos(psi),0.,0.,
//           0.,0.,1.,0.,
//           0.,0.,0.,1.);
//    }

    mat4 viewport = mat4(
       (2.0 / widthRatio), 0, 0, 0,
                     0, 2, 0, 0,
                     0, 0,-1, 0,
                    -1,-1, 0, 1);

    float width = length(r);
    void main () {
        vcoord = position;
        float maxed = sqrt(width * width + height * height);
        vec2 sized = vec2(position * vec2(maxed * 2. * px , maxed * 2. * px));
        mat4 move = translate(
           (p.x - viewportOffset.x * scrollRatio.x - maxed) * px,
           (p.y - viewportOffset.y * scrollRatio.y - maxed) * px,
           0.0
        );

//        float angle = atan(r.y/r.x);
//        mat4 rotate = translate(width * px , height * px , 0.) *
//            RotateZ(angle)
//        * translate(-width * px, -height * px , 0.);
        gl_Position =  viewport * move *  vec4(sized, 0, 1.0);
    }

    |]
