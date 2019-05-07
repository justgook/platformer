module Layer.Object.Common exposing (vertexShader, vertexShaderHalfDimension, vertexShaderWithRotation)

import Math.Vector2 exposing (Vec2)
import WebGL exposing (Mesh, Shader)


vertexShader :
    Shader
        { a
            | position : Vec2
        }
        { b
            | height : Float
            , pixelsPerUnit : Float
            , scrollRatio : Vec2
            , viewportOffset : Vec2
            , width : Float
            , widthRatio : Float
            , x : Float
            , y : Float
        }
        { vcoord : Vec2 }
vertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        uniform float widthRatio;
        uniform float pixelsPerUnit;
        uniform float x;
        uniform float y;
        uniform float height;
        uniform float width;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        varying vec2 vcoord;

        float px = 1.0 / pixelsPerUnit;
        //https://gist.github.com/patriciogonzalezvivo/986341af1560138dde52
        mat4 translate(float x, float y, float z) {
            return mat4(
                vec4(1.0, 0.0, 0.0, 0.0),
                vec4(0.0, 1.0, 0.0, 0.0),
                vec4(0.0, 0.0, 1.0, 0.0),
                vec4(x,   y,   z,   1.0)
            );
        }

        mat4 viewport = mat4(
            (2.0 / widthRatio), 0, 0, 0,
		 	                 0, 2, 0, 0,
		 			         0, 0,-1, 0,
		 			        -1,-1, 0, 1);
        void main () {
            vcoord = position;
//            vec2 fullScreen = vec2(position.x * widthRatio, position.y);
            vec2 sized = vec2(position * vec2(width * px, height * px));
            mat4 move = translate(
                (x - viewportOffset.x * scrollRatio.x - width / 2.) * px,
                (y - viewportOffset.y * scrollRatio.y - height / 2.) * px,
                0.0
            );
            gl_Position = viewport * move * vec4(sized, 0, 1.0);
        }
    |]


vertexShaderWithRotation :
    Shader
        { a
            | position : Vec2
            , angle : Float
        }
        { b
            | height : Float
            , pixelsPerUnit : Float
            , scrollRatio : Vec2
            , viewportOffset : Vec2
            , width : Float
            , widthRatio : Float
            , x : Float
            , y : Float
        }
        { vcoord : Vec2 }
vertexShaderWithRotation =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        attribute float angle;
        uniform float widthRatio;
        uniform float pixelsPerUnit;
        uniform float x;
        uniform float y;
        uniform float height;
        uniform float width;
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
        mat4 RotateZ(float psi){
           return mat4(
               vec4(cos(psi),-sin(psi),0.,0),
               vec4(sin(psi),cos(psi),0.,0.),
               vec4(0.,0.,1.,0.),
               vec4(0.,0.,0.,1.));
        }

        mat4 viewport = mat4(
           (2.0 / widthRatio), 0, 0, 0,
                         0, 2, 0, 0,
                         0, 0,-1, 0,
                        -1,-1, 0, 1);


        void main () {
           vcoord = position;
//           vec2 fullScreen = vec2(position.x * widthRatio, position.y);
           vec2 sized = vec2(position * vec2(width * px, height * px));
           mat4 move = translate(
               (x - viewportOffset.x * scrollRatio.x - width / 2.) * px,
               (y - viewportOffset.y * scrollRatio.y - height / 2.) * px,
               0.0
           );
           mat4 rotate = translate(width * px / 2., height * px /2., 0.) * RotateZ(angle) * translate(-width * px / 2., -height * px / 2., 0.) ;

           gl_Position = viewport * move * rotate * vec4(sized, 0, 1.0);
        }
   |]


vertexShaderHalfDimension :
    Shader
        { a
            | position : Vec2
        }
        { b
            | height : Float
            , pixelsPerUnit : Float
            , scrollRatio : Vec2
            , viewportOffset : Vec2
            , width : Float
            , widthRatio : Float
            , x : Float
            , y : Float
        }
        { vcoord : Vec2 }
vertexShaderHalfDimension =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        uniform float widthRatio;
        uniform float pixelsPerUnit;
        uniform float x;
        uniform float y;
        uniform float height;
        uniform float width;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        varying vec2 vcoord;

        float px = 1.0 / pixelsPerUnit;
        //https://gist.github.com/patriciogonzalezvivo/986341af1560138dde52
        mat4 translate(float x, float y, float z) {
            return mat4(
                vec4(1.0, 0.0, 0.0, 0.0),
                vec4(0.0, 1.0, 0.0, 0.0),
                vec4(0.0, 0.0, 1.0, 0.0),
                vec4(x,   y,   z,   1.0)
            );
        }

        mat4 viewport = mat4(
            (2.0 / widthRatio), 0, 0, 0,
		 	                 0, 2, 0, 0,
		 			         0, 0,-1, 0,
		 			        -1,-1, 0, 1);
        void main () {
            vcoord = position;
//            vec2 fullScreen = vec2(position.x * widthRatio, position.y);
            vec2 sized = vec2(position * vec2(width * 2. * px, height * 2. * px));
            mat4 move = translate(
                (x - viewportOffset.x * scrollRatio.x - width) * px,
                (y - viewportOffset.y * scrollRatio.y - height) * px,
                0.0
            );
            gl_Position = viewport * move * vec4(sized, 0, 1.0);
        }
    |]
