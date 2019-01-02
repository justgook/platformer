module Layer.Image exposing (Model, render)

import Layer.Common exposing (Layer(..), Uniform, mesh, vertexShader)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend
import WebGL.Texture exposing (Texture)


type alias Model =
    { image : Texture }


render : Layer Model -> WebGL.Entity
render (Layer common individual) =
    { pixelsPerUnit = common.pixelsPerUnit
    , viewportOffset = common.viewportOffset
    , widthRatio = common.widthRatio
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , image = individual.image
    }
        |> WebGL.entityWith
            [ WebGL.cullFace WebGL.front
            , Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha
            , WebGL.colorMask True True True False
            ]
            vertexShader
            fragmentShader
            mesh


fragmentShader : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;

        uniform sampler2D image;
        uniform vec3 transparentcolor;
        uniform float pixelsPerUnit;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;

        float px = 1.0 / pixelsPerUnit;

        void main () {
            gl_FragColor = texture2D(image, mod(vcoord + viewportOffset * px * scrollRatio, 1.0) );
            gl_FragColor.rgb *= gl_FragColor.a;
            if (gl_FragColor.xyz == transparentcolor) {
                discard;
            }
        }
    |]
