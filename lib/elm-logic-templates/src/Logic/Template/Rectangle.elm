module Logic.Template.Rectangle exposing (Model, Model2, draw, draw2)

import Logic.Template.Internal exposing (Plate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector4 exposing (Vec4)
import WebGL exposing (Mesh, Shader)


type alias Model a =
    { a
        | width : Float
        , height : Float
        , color : Vec4
    }


type alias Model2 a =
    { a
        | p : Vec2
        , r : Vec2
        , px : Float
        , height : Float
        , color : Vec4
    }


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader
        plate


draw2 : WebGL.Shader Plate (Model2 a) { uv : Vec2 } -> Model2 a -> WebGL.Entity
draw2 vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader2
        plate


fragmentShader : Shader {} (Model a) { uv : Vec2 }
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


fragmentShader2 : WebGL.Shader {} (Model2 a) { uv : Vec2 }
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
//            uv_ -= vec2(0.5);
//
//
//            uv_ = rotate2d(r) * uv_;
//
//            uv_ = scale( vec2 (maxed / width, maxed / height)) * uv_;
//
//            uv_ += vec2(0.5);
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
--vertexShaderForFragmentRotation :
--    Shader
--        { a
--            | position : Vec2
--        }
--        { b
--            | height : Float
--            , r : Vec2
--            , viewport : Mat4
--            , px : Float
--
--            --            , pixelsPerUnit : Float
--            --                        , scrollRatio : Vec2
--            , offset : Vec2
--
--            --            , aspectRatio : Float
--            , p : Vec2
--        }
--        { uv : Vec2 }


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
