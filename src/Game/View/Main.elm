module Game.View.Main exposing (fragmentShader, mesh, vertexShader)

import Math.Vector2 exposing (Vec2, vec2)
import WebGL exposing (Mesh, Shader)


type alias Vertex =
    { position : Vec2 }


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


vertexShader : Shader { a | position : Vec2 } { b | widthRatio : Float } { vcoord : Vec2 }
vertexShader =
    [glsl|
        attribute vec2 position;
        uniform float widthRatio;
        varying vec2 vcoord;
        mat4 viewport = mat4(
            (2.0 / widthRatio), 0, 0, 0,
		 	                 0, 2, 0, 0,
		 			         0, 0,-1, 0,
		 			        -1,-1, 0, 1);
        void main () {
          vcoord = vec2(position.x * widthRatio, position.y);
          gl_Position = viewport * vec4(vcoord, 0, 1.0);
        }
    |]


fragmentShader : Shader a b { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        void main () {
            gl_FragColor = vec4(1, 0, 0, 1);
            if (vcoord.x < .95 && vcoord.x > .05 && vcoord.y < .95 && vcoord.y > .05) {
                 gl_FragColor.a = 0.25;
            }
        }
    |]
