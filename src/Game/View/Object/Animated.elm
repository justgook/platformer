module Game.View.Object.Animated exposing (render)

import Game.View.Main exposing (mesh)
import Game.View.Object exposing (vertexShader)
import WebGL exposing (Shader, Texture)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)


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


type alias Model =
    { columns : Int
    , frame : Int

    -- , frameSize : Vec2
    , imageSize : Vec2
    , frames : Int
    , height : Float
    , width : Float
    , lut : Texture
    , mirror : Int
    , pixelsPerUnit : Float
    , scrollRatio : Vec2
    , sprite : Texture
    , started : Int
    , transparentcolor : Vec3
    , viewportOffset : Vec2
    , widthRatio : Float
    , x : Float
    , y : Float
    }


fragmentShader : Shader {} Model { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform sampler2D sprite;
        uniform sampler2D lut;
        uniform int frame;
        uniform vec3 transparentcolor;
        uniform int frames;
        uniform int started;
        uniform vec2 imageSize;
        uniform int columns;
        uniform int mirror;

        uniform float height;
        uniform float width;

        float runtime = abs(float(frame) - float(started));
        float fFrames = float(frames);
        float LUTpixel = floor(runtime - floor((runtime + 0.5) / fFrames) * fFrames + 0.5);
        float LUTpixelCoord = floor(LUTpixel * 2. + 1.) / (fFrames * 2.); //(2i + 1)/(2N) -  pixel center

        float color2float(vec4 c){
            return c.z * 255.0
            + c.y * 256.0 * 255.0
            + c.x * 256.0 * 256.0 * 255.0
            ;
        }

        float modI(float a,float b) {
            float m = a - floor((a + 0.5) / b) * b;
            return floor(m + 0.5);
        }

        void main () {
            vec4 takeFromSprite = texture2D(lut, vec2(LUTpixelCoord, 0.5)); //Only one pixel height - so y can be anythink
            float tileId = color2float(takeFromSprite);
            float xOffset = modI(tileId, float(columns)) * width; // Ugly float rounding fix
            float yOffset = (float(columns) - floor(tileId / float(columns))) * height; // Some magic to invert calculation form top to bottom

            vec2 look = floor(vcoord * vec2(width, height));

            if (mirror > 1 ) { //0x10
                look.x = width - look.x;
            }
            if (mirror == 1 || mirror == 3) { //0x01
                look.y = height - look.y;
            }
            vec2 pixel = floor( (look + vec2(xOffset, yOffset))  * 2. + 1.) / (imageSize * 2.);
            gl_FragColor = texture2D(sprite, pixel);
            gl_FragColor.rgb *= gl_FragColor.a;
            if (gl_FragColor.rgb == transparentcolor) {
                discard;
            }
        }
    |]
