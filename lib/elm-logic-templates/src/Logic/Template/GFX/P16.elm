module Logic.Template.GFX.P16 exposing (Particles, empty, points, render, updateShaderData, vertexShader)

import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector4 exposing (Vec4, vec4)
import WebGL exposing (Mesh, Shader)
import WebGL.Settings exposing (Setting)


type alias Particles =
    { aspectRatio : Float
    , viewportOffset : Vec2
    , p0 : Vec4
    , p1 : Vec4
    , p2 : Vec4
    , p3 : Vec4
    , p4 : Vec4
    , p5 : Vec4
    , p6 : Vec4
    , p7 : Vec4
    , p8 : Vec4
    , p9 : Vec4
    , p10 : Vec4
    , p11 : Vec4
    , p12 : Vec4
    , p13 : Vec4
    , p14 : Vec4
    , p15 : Vec4
    }


render : List Setting -> WebGL.Shader {} Particles { data : Math.Vector4.Vec4 } -> Particles -> WebGL.Entity
render entitySettings fragmentShader =
    WebGL.entityWith
        entitySettings
        vertexShader
        fragmentShader
        points


empty : Particles
empty =
    { aspectRatio = 0
    , viewportOffset = Vec2.vec2 0 0
    , p0 = vec4 0 0 0 0
    , p1 = vec4 0 0 0 0
    , p2 = vec4 0 0 0 0
    , p3 = vec4 0 0 0 0
    , p4 = vec4 0 0 0 0
    , p5 = vec4 0 0 0 0
    , p6 = vec4 0 0 0 0
    , p7 = vec4 0 0 0 0
    , p8 = vec4 0 0 0 0
    , p9 = vec4 0 0 0 0
    , p10 = vec4 0 0 0 0
    , p11 = vec4 0 0 0 0
    , p12 = vec4 0 0 0 0
    , p13 = vec4 0 0 0 0
    , p14 = vec4 0 0 0 0
    , p15 = vec4 0 0 0 0
    }


points : Mesh { index : Float }
points =
    WebGL.points
        [ { index = 0 }
        , { index = 1 }
        , { index = 2 }
        , { index = 3 }
        , { index = 4 }
        , { index = 5 }
        , { index = 6 }
        , { index = 7 }
        , { index = 8 }
        , { index = 9 }
        , { index = 10 }
        , { index = 11 }
        , { index = 12 }
        , { index = 13 }
        , { index = 14 }
        , { index = 15 }
        ]


updateShaderData : Int -> Vec4 -> Particles -> Particles
updateShaderData i data allParticles =
    case i of
        0 ->
            { allParticles | p0 = data }

        1 ->
            { allParticles | p1 = data }

        2 ->
            { allParticles | p2 = data }

        3 ->
            { allParticles | p3 = data }

        4 ->
            { allParticles | p4 = data }

        5 ->
            { allParticles | p5 = data }

        6 ->
            { allParticles | p6 = data }

        7 ->
            { allParticles | p7 = data }

        8 ->
            { allParticles | p8 = data }

        9 ->
            { allParticles | p9 = data }

        10 ->
            { allParticles | p10 = data }

        11 ->
            { allParticles | p11 = data }

        12 ->
            { allParticles | p12 = data }

        13 ->
            { allParticles | p13 = data }

        14 ->
            { allParticles | p14 = data }

        15 ->
            { allParticles | p15 = data }

        _ ->
            allParticles


vertexShader : WebGL.Shader { index : Float } Particles { data : Vec4 }
vertexShader =
    [glsl|
precision mediump float;
attribute float index;
uniform float aspectRatio;
uniform vec4 p0;
uniform vec4 p1;
uniform vec4 p2;
uniform vec4 p3;
uniform vec4 p4;
uniform vec4 p5;
uniform vec4 p6;
uniform vec4 p7;
uniform vec4 p8;
uniform vec4 p9;
uniform vec4 p10;
uniform vec4 p11;
uniform vec4 p12;
uniform vec4 p13;
uniform vec4 p14;
uniform vec4 p15;
varying vec4 data;
uniform vec2 viewportOffset;

mat4 viewport = mat4((2.0 / aspectRatio), 0, 0, 0, 0, 2, 0, 0, 0, 0, -1, 0, -1, -1, 0, 1);

void main() {
    data = vec4(0., 0., 0., 0.);
    if(index == 0.) { data = p0; };
    if(index == 1.) { data = p1; };
    if(index == 2.) { data = p2; };
    if(index == 3.) { data = p3; };
    if(index == 4.) { data = p4; };
    if(index == 5.) { data = p5; };
    if(index == 6.) { data = p6; };
    if(index == 7.) { data = p7; };
    if(index == 8.) { data = p8; };
    if(index == 9.) { data = p9; };
    if(index == 10.) { data = p10; };
    if(index == 11.) { data = p11; };
    if(index == 12.) { data = p12; };
    if(index == 13.) { data = p13; };
    if(index == 14.) { data = p14; };
    if(index == 15.) { data = p15; };
    vec2 move = vec2(
       (data.x - viewportOffset.x),
       (data.y - viewportOffset.y)
    );
    gl_Position = viewport *  vec4(data.xy + move, 0, 1.0);
    gl_PointSize = data.z;
}
    |]
