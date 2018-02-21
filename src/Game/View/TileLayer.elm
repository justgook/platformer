module Game.View.TileLayer exposing (render)

import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL exposing (Mesh, Shader, Texture)
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


type alias Vertex =
    { position : Vec2 }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec2 0 1)
          , Vertex (vec2 1 0)
          , Vertex (vec2 0 0)
          )
        , ( Vertex (vec2 0 1)
          , Vertex (vec2 1 1)
          , Vertex (vec2 1 0)
          )
        ]


vertexShader : Shader { a | position : Vec2 } { b | widthRatio : Float } { vcoord : Vec2 }
vertexShader =
    [glsl|
        attribute vec2 position;
        uniform float widthRatio;
        varying vec2 vcoord;
        mat4 viewport = mat4(
            (2.0 / widthRatio), 0, 0, 0,
		 	                 0, 2, 0, 0,
		 			         0, 0,-1, 0,
		 			        -1,-1, 0, 1);
        void main () {
          vcoord = vec2(position.x * widthRatio, position.y);
          gl_Position = viewport * vec4(vcoord, 0, 1.0);
        }
    |]


fragmentShader : Shader a Model { vcoord : Vec2 }
fragmentShader =
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
        float tilesPerUnit = pixelsPerUnit / tileSize.y;
        uniform vec2 viewportOffset; // Uniform based charracter position (maybe add some moving animation, that follows character)
        float LUTprecision = 10000.0; //Pixels of LUT need to find real value, and how to ubdate precision of vcoord

        vec2 levelPoint(float tilesPerUnit, vec2 vcoord, vec2 viewportOffset);
        vec4 pixelFromTile(sampler2D image, vec2 size, float index, vec2 fragmentOffset, bool readFromTop);
        void main() {
            vec2 point = levelPoint(tilesPerUnit, vcoord, viewportOffset);
            vec2 look = floor(point); // or add precision here ?
            float tileIndex = ((texture2D(lut, vec2(look.x / lutSize.x, look.y / lutSize.y)).z * 255.0));
            //int tileIndex = 2;
            if (tileIndex == 0.0) { //empty
                discard;
            } else {
                gl_FragColor = pixelFromTile(tileSet, tileSetSize, tileIndex - 1.0, point - look, true);
            }
            if (gl_FragColor.xyz == transparentcolor) {
                discard;
            }
        }

        vec2 vec2Round(vec2 what, float how) {
            return floor(what * how + 0.5) / how;
        }

        vec2 levelPoint(float tilesPerUnit, vec2 vcoord, vec2 viewportOffset) {
            float levelX = ((vcoord.x / (1.0 / tilesPerUnit))) + viewportOffset.x;
            float levelY = ((vcoord.y / (1.0 / tilesPerUnit))) + viewportOffset.y;
            return vec2Round(vec2(levelX, levelY), LUTprecision); //TODO find real problem!
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
