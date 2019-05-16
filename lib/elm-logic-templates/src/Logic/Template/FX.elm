module Logic.Template.FX exposing (draw)


draw =
    ""



{---
((count)=>`

type alias Particles =
    { aspectRatio : Float
    , ${[...Array(count).keys()].map((i) => `p${i} : Vec4`).join("\n    , ")}
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
    , ${[...Array(count).keys()].map((i) => `p${i} = vec4 ${i / count + 1 / count} ${i / count + 1 / count} ${i+10} ${i / count + 1 / count}`).join("\n    , ")}
    }


points : Mesh { index : Float }
points =
    WebGL.points
        [ ${[...Array(count).keys()].map((i) => `{ index = ${i} }`).join("\n        , ")}
        ]


updateShaderData : Int -> Vec4 -> Particles -> Particles
updateShaderData i data allParticles =
    case i of
        ${[...Array(count).keys()].map((i) => `${i} ->\n            { allParticles | p${i} = data }`).join("\n\n        ")}

        _ ->
            allParticles


vertexShader : WebGL.Shader { index : Float } Particles { data : Vec4 }
vertexShader =
    [glsl|
precision mediump float;
attribute float index;
uniform float aspectRatio;
${[...Array(count).keys()].map((i) =>`uniform vec4 p${i};`).join("\n")}
varying vec4 data;
mat4 viewport = mat4((2.0 / aspectRatio), 0, 0, 0, 0, 2, 0, 0, 0, 0, -1, 0, -1, -1, 0, 1);
void main() {
    data = vec4(0., 0., 0., 0.);
    ${[...Array(count).keys()].map((i) => `if(index == ${i}.) { data = p${i}; };`).join("\n    ")}
    gl_Position = viewport * vec4(data.xy, 0, 1.0);
    gl_PointSize = data.z;
}
    |]

`)(128)

-}
