module Game.View.TileLayer exposing (Model, render)

import Game.View.Main exposing (mesh, vertexShader)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader, Texture)
import WebGL.Settings as WebGL
import WebGL.Settings.Blend as Blend


type alias Model =
    { lut : Texture
    , lutSize : Vec2
    , tileSet : Texture
    , tileSetSize : Vec2
    , pixelsPerUnit : Float
    , transparentcolor : Vec3
    , viewportOffset : Vec2
    , tileSize : Vec2
    , widthRatio : Float
    , firstgid : Int
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



-- https://stackoverflow.com/questions/5879403/opengl-texture-coordinates-in-pixel-space/5879551#5879551
-- https://gamedev.stackexchange.com/questions/121051/webgl-pixel-perfect-tilemap-rendering


fragmentShader : Shader a Model { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform sampler2D tileSet;
        uniform sampler2D lut;
        uniform int firstgid;
        uniform vec3 transparentcolor;
        uniform vec2 lutSize;
        uniform vec2 tileSetSize;
        uniform float pixelsPerUnit;
        uniform vec2 tileSize;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        vec2 imageSizePx = tileSetSize * tileSize;
        vec2 tilesPerUnit = pixelsPerUnit / tileSize;

        vec2 levelPoint(vec2 tilesPerUnit, vec2 vcoord, vec2 viewportOffset);
        vec4 pixelFromTile(sampler2D image, vec2 size, float index, vec2 fragmentOffset, bool readFromTop);
        float color2float(vec4 c) {
            return c.z * 255.0
            + c.y * 256.0 * 255.0
            + c.x * 256.0 * 256.0 * 255.0
            ;
        }

        void main() {
            vec2 test = viewportOffset / tileSize.y;
            vec2 point = levelPoint(tilesPerUnit, vcoord, test);
            vec2 look = floor(point); // or add precision here ?
            //(2i + 1)/(2N)
            vec2 coordinate = (look * 2. + 1.) / (lutSize * 2.);
            float tileIndex = color2float(texture2D(lut, coordinate));
            if (tileIndex == 0.0) { //empty
                discard;
            }
            else {
                gl_FragColor = pixelFromTile(tileSet, tileSetSize, tileIndex - float(firstgid), point - look, true);
            }
            if (gl_FragColor.rgb == transparentcolor || gl_FragColor.a == 0.0) {
                discard;
            }
        }

        vec2 levelPoint(vec2 tilesPerUnit, vec2 vcoord, vec2 viewportOffset) {
            vec2 result = ((vcoord / (1.0 / tilesPerUnit))) + viewportOffset * scrollRatio;
            return result;
        }

        float modI(float a,float b) {
            float m = a - floor((a + 0.5) / b) * b;
            return floor(m + 0.5);
        }

        vec4 pixelFromTile(sampler2D image, vec2 size, float index, vec2 fragmentOffset, bool readFromTop) {
            float columns = size.x;
            float rows = size.y;
            vec2 fragmentOffsetPx = floor(fragmentOffset * tileSize);
            vec2 tile = vec2(modI(index, columns), floor(index / columns));
            if (readFromTop) {
                tile.y = rows - tile.y - 1.;
            }
            vec2 pixel = floor((tile * 16. + fragmentOffsetPx)  * 2. + 1.) / (imageSizePx * 2.);
            return texture2D(image, pixel);
        }
    |]
