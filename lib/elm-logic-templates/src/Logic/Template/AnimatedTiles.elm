module Logic.Template.AnimatedTiles exposing (Model, draw)

import Logic.Template.Internal exposing (Plate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)


type alias Model a =
    { a
        | offset : Vec2
        , px : Float
        , uTransparentColor : Vec3
        , uLut : Texture
        , uLutSize : Vec2
        , animLUT : Texture
        , animLength : Int
        , uAtlas : Texture
        , uAtlasSize : Vec2
        , uTileSize : Vec2
        , time : Int
    }


draw : Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader
        plate


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    --TODO /Add suport for tiles-sets that is bigger than level tile size
    -- need to create loop that go over all posible covered neighbours and merge resulting pixel (alpha level including)
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform sampler2D uAtlas;
        uniform sampler2D uLut;
        uniform vec3 uTransparentColor;
        uniform vec2 uLutSize;
        uniform vec2 uAtlasSize;
        uniform float px;
        uniform vec2 uTileSize;
//        uniform vec2 viewportOffset;
//        uniform vec2 scrollRatio;
        uniform sampler2D animLUT;
        uniform int animLength;
        uniform int time;
        float animLength_ = float(animLength);
        float time_ = float(time);

        vec2 tilesPerUnit = uTileSize * px;
//        float px = 1.0 / pixelsPerUnit;

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
            vec2 point = ((uv / (1.0 / tilesPerUnit)));// + (viewportOffset / uTileSize) * scrollRatio;
            vec2 look = floor(point);

            //(2i + 1)/(2N) Pixel center
            vec2 coordinate = (look + 0.5) / uLutSize;
            float currentFrame = modI(time_, animLength_) + 0.5; // Middle of pixel
            float newIndex = color2float(texture2D(animLUT, vec2(currentFrame / animLength_, 0.5 ))) + 1.;
            float uIndex = color2float(texture2D(uLut, coordinate)) * newIndex;
//            uIndex = uIndex - 1.; // tile indexes in uAtlas starts from zero, but in lut zero is used for "none" placeholder
            vec2 grid = uAtlasSize / uTileSize;
            vec2 tile = vec2(modI((uIndex - 1.), grid.x), int(uIndex - 1.) / int(grid.x));
            // inverting reading botom to top
            tile.y = grid.y - tile.y - 1.;

            vec2 fragmentOffsetPx = floor((point - look) * uTileSize);

            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(tile * uTileSize + fragmentOffsetPx) + 0.5) / uAtlasSize;
            gl_FragColor = texture2D(uAtlas, pixel);

            gl_FragColor.a *= float(uIndex >= 0.) * float(gl_FragColor.rgb != uTransparentColor);

//            gl_FragColor.rgb = vec3(1.,0., mod(floor(uv / px + 0.5), 2.));
//            gl_FragColor.rgb *= gl_FragColor.a;

        }
    |]
