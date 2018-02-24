module Game.View.Object exposing (fragmentShader, mesh, render, vertexShader)

-- import Math.Vector3 exposing (Vec3, vec3)

import Math.Vector2 exposing (Vec2, vec2)
import WebGL exposing (Mesh, Shader, Texture)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend


render : { a | pixelsPerUnit : Float, x : Float, y : Float, height : Float, width : Float, widthRatio : Float } -> WebGL.Entity
render uniforms =
    WebGL.entityWith
        [ WebGL.cullFace WebGL.front
        , Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha
        , WebGL.colorMask True True True False
        ]
        vertexShader
        fragmentShader
        mesh
        uniforms


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          , Vertex (vec2 0 0)
          )
        , ( Vertex (vec2 0 1)
          , Vertex (vec2 1 1)
          , Vertex (vec2 1 0)
          )
        ]


type alias Vertex =
    { position : Vec2 }


fragmentShader : Shader a b { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        void main () {
            gl_FragColor = vec4(1, 0, 0, 0.75);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


vertexShader : Shader { a | position : Vec2 } { b | height : Float, pixelsPerUnit : Float, width : Float, widthRatio : Float, x : Float, y : Float } { vcoord : Vec2 }
vertexShader =
    [glsl|
        attribute vec2 position;
        uniform float widthRatio;
        uniform float pixelsPerUnit;
        uniform float x;
        uniform float y;
        uniform float height;
        uniform float width;
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
            float yPos = 1.0 - (height + y) * px; //Reverse it becouse Tiled is TopLeft - GLSL BottomLeft
            gl_Position = viewport * translate(x * px, yPos, 0.0) * vec4(
              vec2(position * vec2(width * px, height * px)),
              0, 1.0);
        }
    |]
