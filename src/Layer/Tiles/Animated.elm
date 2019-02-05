module Layer.Tiles.Animated exposing (Model, render)

import Defaults exposing (default)
import Layer.Common exposing (Layer(..), Uniform, mesh, vertexShader)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend
import WebGL.Texture exposing (Texture)


type alias Model =
    { lut : Texture
    , lutSize : Vec2
    , animLUT : Texture
    , animLength : Int
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    }


render : Layer Model -> WebGL.Entity
render (Layer common individual) =
    { pixelsPerUnit = common.pixelsPerUnit
    , viewportOffset = common.viewportOffset
    , widthRatio = common.widthRatio
    , time = common.time
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , lut = individual.lut
    , lutSize = individual.lutSize
    , animLUT = individual.animLUT
    , animLength = individual.animLength
    }
        |> WebGL.entityWith
            default.entitySettings
            vertexShader
            fragmentShader
            mesh



-- https://stackoverflow.com/questions/5879403/opengl-texture-coordinates-in-pixel-space/5879551#5879551
-- https://gamedev.stackexchange.com/questions/121051/webgl-pixel-perfect-tilemap-rendering


fragmentShader : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShader =
    --TODO /Add suport for tiles-sets that is bigger than level tile size
    -- need to create loop that go over all posible covered neighbours and merge resulting pixel (alpha level including)
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform sampler2D tileSet;
        uniform sampler2D lut;
        uniform vec3 transparentcolor;
        uniform vec2 lutSize;
        uniform vec2 tileSetSize;
        uniform float pixelsPerUnit;
        uniform vec2 tileSize;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform sampler2D animLUT;
        uniform int animLength;
        uniform int time;
        float animLength_ = float(animLength);
        float time_ = float(time);

        vec2 tilesPerUnit = pixelsPerUnit / tileSize;
        //float px = 1.0 / pixelsPerUnit;

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
            vec2 point = ((vcoord / (1.0 / tilesPerUnit))) + viewportOffset * scrollRatio;
            vec2 look = floor(point);

            //(2i + 1)/(2N) Pixel center
            vec2 coordinate = (look + 0.5) / lutSize;
            float currentFrame = modI(time_, animLength_);
            float newIndex = color2float(texture2D(animLUT, vec2(currentFrame / animLength_, 0.5 ))) + 1.;
            float tileIndex = color2float(texture2D(lut, coordinate)) * newIndex;
            float magic = tileIndex / tileIndex;
            tileIndex = tileIndex - 1.; // tile indexes in tileset starts from zero, but in lut zero is used for "none" placeholder
            vec2 grid = tileSetSize / tileSize;
            vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));
            // inverting reading botom to top
            tile.y = grid.y - tile.y - 1.;

            vec2 fragmentOffsetPx = floor((point - look) * tileSize);

            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;
            gl_FragColor = texture2D(tileSet, pixel);

            gl_FragColor.a *= magic;
            gl_FragColor.rgb *= gl_FragColor.a;

        }
    |]



-- float magic = tileIndex / tileIndex;
-- tileIndex = tileIndex - 1.; // tile indexes in tileset starts from zero, but in lut zero is used for "none" placeholder
-- vec2 grid = tileSetSize / tileSize;
-- vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));
-- // inverting reading botom to top
-- tile.y = grid.y - tile.y - 1.;
-- vec2 fragmentOffsetPx = floor((point - look) * tileSize);
-- //(2i + 1)/(2N) Pixel center
-- vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;
-- gl_FragColor = texture2D(tileSet, pixel);
-- gl_FragColor.a *= magic;
-- gl_FragColor.rgb *= gl_FragColor.a;
