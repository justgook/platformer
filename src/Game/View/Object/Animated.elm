module Game.View.Object.Animated exposing (render)

import Game.View.Object exposing (mesh, vertexShader)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL exposing (Mesh, Shader, Texture)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend


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


fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform sampler2D sprite;
        uniform float runtime;
        uniform vec3 transparentcolor;

        float test = floor(mod(runtime * 10.0, 8.0));
        float frame = test / 8.0;

        void main () {
            gl_FragColor = texture2D(sprite, vec2(frame + vcoord.x / 8.0, vcoord.y));
            gl_FragColor.rgb *= gl_FragColor.a;
            if (gl_FragColor.xyz == transparentcolor) {
                discard;
            }
        }
    |]
