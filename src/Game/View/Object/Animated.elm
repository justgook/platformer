module Game.View.Object.Animated exposing (render)

import Game.View.Main exposing (mesh)
import Game.View.Object exposing (vertexShader)
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
        uniform sampler2D lut;
        uniform int frame;
        uniform vec3 transparentcolor;
        uniform float frames;
        uniform int started;
        uniform vec2 frameSize;
        uniform float columns;
        uniform int mirror;
        float runtime = abs(float(frame - started));
        float LUTpixel = floor(mod(runtime, frames));

        float color2float(vec4 c){
            return c.z * 255.0
            + c.y * 256.0 * 255.0
            + c.x * 256.0 * 256.0 * 255.0
            ;
        }
        void main () {
            vec4 takeFromSprite = texture2D(lut, vec2(LUTpixel / frames, 0)); //Only one pixel height - so y can be anythink
            float frame = color2float(takeFromSprite);
            float yOffset = (1.0 / frameSize.y) - floor(frame / columns) - 1.0; // Some magic to invert calculation form top to bottom
            float xOffset = mod(frame, columns);
            vec2 mirrored = vcoord;

            if (mirror > 1 ) { //0x10
                mirrored.x = 1. - vcoord.x;
            }
            if (mirror == 1 || mirror == 3) { //0x01
                mirrored.y = 1. - vcoord.y;
            }

            vec2 result = (mirrored + vec2(xOffset, yOffset));
            gl_FragColor = texture2D(sprite, result  * frameSize);
            gl_FragColor.rgb *= gl_FragColor.a;
            if (gl_FragColor.xyz == transparentcolor) {
                discard;
            }
        }
    |]
