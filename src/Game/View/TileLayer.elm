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

        vec2 tilesPerUnit = pixelsPerUnit / tileSize;
        float LUTprecision = 10000.0; //Pixels of LUT need to find real value, and how to ubdate precision of vcoord

        vec2 levelPoint(vec2 tilesPerUnit, vec2 vcoord, vec2 viewportOffset);
        vec4 pixelFromTile(sampler2D image, vec2 size, float index, vec2 fragmentOffset, bool readFromTop);
        float color2float(vec4 c){
            return c.z * 255.0
            + c.y * 256.0 * 255.0
            + c.x * 256.0 * 256.0 * 255.0
            ;
        }
        void main() {
            vec2 point = levelPoint(tilesPerUnit, vcoord, viewportOffset / tileSize.y);
            vec2 look = floor(point); // or add precision here ?
            float tileIndex = color2float(texture2D(lut, vec2(look.x / lutSize.x, look.y / lutSize.y)));
            if (tileIndex == 0.0) { //empty
                discard;
            } else {
                gl_FragColor = pixelFromTile(tileSet, tileSetSize, tileIndex - float(firstgid), point - look, true);
            }
            if (gl_FragColor.rgb == transparentcolor || gl_FragColor.a == 0.0) {
                discard;
            }
        }

        vec2 vec2Round(vec2 what, float how) {
            return floor(what * how + 0.5) / how;
        }

        vec2 levelPoint(vec2 tilesPerUnit, vec2 vcoord, vec2 viewportOffset) {
            // float levelX = ((vcoord.x / (1.0 / tilesPerUnit.x))) + viewportOffset.x * scrollRatio.x;
            // float levelY = ((vcoord.y / (1.0 / tilesPerUnit.y))) + viewportOffset.y * scrollRatio.y;
            vec2 result = ((vcoord / (1.0 / tilesPerUnit))) + viewportOffset * scrollRatio;
            return vec2Round(result, LUTprecision); //TODO find real problem!
        }

        vec4 pixelFromTile(sampler2D image, vec2 size, float index, vec2 fragmentOffset, bool readFromTop) {
            float columns = size.x;
            float rows = size.y;
            vec2 tileSize = vec2(1.0 / columns, 1.0 / rows);
            //add margins and spacings...
            vec2 tileStart = vec2(mod(index, columns), floor(index / columns)) * tileSize;
            if (readFromTop) {
                vec2 tileStartTop = vec2(tileStart.x, 1.0 - tileStart.y - tileSize.y);
                vec2 result = tileStartTop + fragmentOffset * tileSize;
                return texture2D(image, vec2(result.x, result.y));
            } else {
                return texture2D(image, tileStart + fragmentOffset * tileSize);
            }
        }
    |]
