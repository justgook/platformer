module Layer.Object.Tile exposing (Model, render)

import Defaults exposing (default)
import Layer.Common exposing (Layer(..), Uniform, mesh)
import Layer.Object.Common exposing (vertexShader)
import Math.Vector2 exposing (Vec2)
import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)


type alias Model =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , tileIndex : Float
    , tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    , mirror : Vec2
    }


render : Layer Model -> WebGL.Entity
render (Layer common individual) =
    { height = individual.height
    , width = individual.width
    , x = individual.x
    , y = individual.y
    , tileSet = individual.tileSet
    , tileSetSize = individual.tileSetSize
    , tileSize = individual.tileSize
    , tileIndex = individual.tileIndex
    , mirror = individual.mirror

    -- General
    , transparentcolor = individual.transparentcolor
    , scrollRatio = individual.scrollRatio
    , pixelsPerUnit = common.pixelsPerUnit
    , viewportOffset = common.viewportOffset
    , widthRatio = common.widthRatio
    , time = common.time
    }
        |> WebGL.entityWith
            default.entitySettings
            vertexShader
            fragmentShader
            mesh


fragmentShader : Shader a (Uniform Model) { vcoord : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 vcoord;
        uniform vec3 transparentcolor;
        uniform sampler2D tileSet;
        uniform vec2 tileSetSize;
        //uniform float pixelsPerUnit;
        uniform vec2 tileSize;
        uniform vec2 mirror;
        uniform vec2 viewportOffset;
        uniform vec2 scrollRatio;
        uniform float tileIndex;

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
            vec2 point = vcoord + (viewportOffset / tileSize) * scrollRatio;
            vec2 grid = tileSetSize / tileSize;
//            vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));
            vec2 tile = vec2(modI((tileIndex), grid.x), int(tileIndex) / int(grid.x));

            // inverting reading botom to top
            tile.y = grid.y - tile.y - 1.;
            vec2 fragmentOffsetPx = floor((point) * tileSize);


            fragmentOffsetPx.x = abs(((tileSize.x - 1.) * mirror.x ) - fragmentOffsetPx.x);
            fragmentOffsetPx.y = abs(((tileSize.y - 1.)  * mirror.y ) - fragmentOffsetPx.y);

            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;

            gl_FragColor = texture2D(tileSet, pixel);
            gl_FragColor.a *= float(gl_FragColor.rgb != transparentcolor);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]
