module Logic.Template.Tiles exposing (Model, draw)

import Logic.Template.Internal exposing (Plate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)


type alias Model a =
    { a
        | px : Float
        , uTransparentColor : Vec3
        , scrollRatio : Vec2
        , uAtlas : Texture
        , uAtlasSize : Vec2
        , uTileSize : Vec2
        , uLut : Texture
        , uLutSize : Vec2
    }


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader
        plate


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    --TODO /Add suport for tiles-sets that is bigger than level tile size
    --    https://gamedevelopment.tutsplus.com/tutorials/creating-isometric-worlds-a-primer-for-game-developers--gamedev-6511
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

float color2float(vec4 color) {
    return
    color.a * 255.0
    + color.b * 256.0 * 255.0
    + color.g * 256.0 * 256.0 * 255.0
    + color.r * 256.0 * 256.0 * 256.0 * 255.0;
    }

float modI(float a, float b) {
   float m = a - floor((a + 0.5) / b) * b;
   return floor(m + 0.5);
}


void main() {
   vec2 point = uv / (px * uTileSize);// + (viewportOffset / uTileSize) * scrollRatio;
   vec2 look = floor(point);
   //(2i + 1)/(2N) Pixel center
   vec2 coordinate = (look + 0.5) / uLutSize;
   float uIndex = color2float(texture2D(uLut, coordinate));
   vec2 grid = uAtlasSize / uTileSize;
   // tile indexes in uAtlas starts from zero, but in lut zero is used for
   // "none" placeholder
   vec2 tile = vec2(modI((uIndex - 1.), grid.x), int(uIndex - 1.) / int(grid.x));
   // inverting reading botom to top
   tile.y = grid.y - tile.y - 1.;
   vec2 fragmentOffsetPx = floor((point - look) * uTileSize);
   //(2i + 1)/(2N) Pixel center
   vec2 pixel = (floor(tile * uTileSize + fragmentOffsetPx) + 0.5) / uAtlasSize;
   gl_FragColor = texture2D(uAtlas, pixel);
   gl_FragColor.a *= float(uIndex > 0.);
   gl_FragColor.rgb *= gl_FragColor.a;
}
    |]
