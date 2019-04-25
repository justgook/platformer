module Layer.Common exposing (Common, Individual, Layer(..), Uniform, mesh, vertexShader)

import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Mesh, Shader)


type alias Vertex =
    { position : Vec2 }


type Layer a
    = Layer Common (Individual a)


type alias Common =
    CommonCommon {}


type alias CommonCommon a =
    { a
        | pixelsPerUnit : Float
        , viewportOffset : Vec2
        , widthRatio : Float
        , time : Int
    }


type alias Uniform a =
    Individual (CommonCommon a)


type alias Individual a =
    { a
        | transparentcolor : Vec3
        , scrollRatio : Vec2
    }


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
        precision mediump float;
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
