module Game.View.ImageLayer exposing (Model, render)

import Game.View.Main exposing (mesh, vertexShader)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader, Texture)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend


type alias Model =
    { image : Texture
    , pixelsPerUnit : Float
    , transparentcolor : Vec3
    , viewportOffset : Vec2
    , widthRatio : Float
    , scrollRatio : Vec2
    }


render : Model -> WebGL.Entity
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


fragmentShader : Shader a Model { vcoord : Vec2 }
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
