module Logic.Template.Layer.Object.Animated exposing (Model, draw)

import Defaults exposing (default)
import Logic.Template.Internal exposing (Plate, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)


type alias Model a =
    { a
        | start : Float
        , tileSet : Texture
        , tileSetSize : Vec2
        , tileSize : Vec2
        , mirror : Vec2
        , animLUT : Texture
        , animLength : Int
        , time : Int
        , transparentcolor : Vec3
    }


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        default.entitySettings
        vertexShader_
        fragmentShader
        plate


fragmentShader_ : Shader {} (Model a) { uv : Vec2 }
fragmentShader_ =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        void main () {
            gl_FragColor = vec4(1.,0.,0.,1.);
        }
    |]


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec3 transparentcolor;
        uniform sampler2D tileSet;
        uniform vec2 tileSetSize;
        uniform vec2 tileSize;
        uniform vec2 mirror;
        uniform sampler2D animLUT;
        uniform int animLength;
        uniform int time;
        uniform float start;
        float animLength_ = float(animLength);
        float time_ = float(time) - start;

        float color2float(vec4 c) {
            return c.z * 255.0
            + c.y * 256.0 * 255.0
            + c.x * 256.0 * 256.0 * 255.0
            ;
        }

        float modI(float a, float b) {
            float m = a - floor((a + 0.5) / b) * b;
            return floor(m + 0.5);
        }

        void main () {
            float currentFrame = modI(time_, animLength_) + 0.5; // Middle of pixel
            float tileIndex = color2float(texture2D(animLUT, vec2(currentFrame / animLength_, 0.5 )));
            vec2 grid = tileSetSize / tileSize;
            vec2 tile = vec2(modI((tileIndex), grid.x), int(tileIndex) / int(grid.x));
            // inverting reading botom to top
            tile.y = grid.y - tile.y - 1.;
            vec2 fragmentOffsetPx = floor((uv) * tileSize);


            //vec2 fragmentOffsetPx = floor(point * tileSize);
            fragmentOffsetPx.x = abs(((tileSize.x - 1.) * mirror.x ) - fragmentOffsetPx.x);
            fragmentOffsetPx.y = abs(((tileSize.y - 1.)  * mirror.y ) - fragmentOffsetPx.y);

            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;

            //gl_FragColor = texture2D(tileSet, pixel);
            gl_FragColor = texture2D(tileSet, pixel);
            gl_FragColor.a *= float(gl_FragColor.rgb != transparentcolor);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]
