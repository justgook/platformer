module Logic.Template.Sprite exposing (Model, draw, draw2, drawCustom, invertFragmentShader, mainFragmentShader)

import Logic.Template.Internal exposing (Plate, clipPlate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)


type alias Model a =
    { a
        | uIndex : Float
        , uAtlas : Texture
        , uAtlasSize : Vec2
        , uTileSize : Vec2
        , uMirror : Vec2
        , uTransparentColor : Vec3
    }


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fragmentShader
        plate



--draw2 : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity


draw2 vertexShader_ =
    WebGL.entityWith
        entitySettings
        vertexShader_
        mainFragmentShader
        clipPlate


drawCustom vertexShader_ fShader =
    WebGL.entityWith
        entitySettings
        vertexShader_
        fShader
        clipPlate


diffusedFragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec3 uTransparentColor;
        uniform sampler2D uAtlas;
        uniform vec2 uAtlasSize;
        uniform vec4 uTileUV;
        uniform vec4 uTileUV;
        uniform vec4 uDiffuseColor;
        void main () {
            vec2 uv_ = uv;
            vec2 pixel = (floor(uv_) + 0.5) / uAtlasSize;
            gl_FragColor = texture2D(uAtlas, pixel);
            gl_FragColor.a *= float(gl_FragColor.rgb != uTransparentColor);
            gl_FragColor.a *= float(uv.y < uTileUV.y + uTileUV.w); //cut last top fragment on to - some bugs appiers..
            gl_FragColor.rgb *= (uDiffuseColor.rgb * uDiffuseColor.a);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


invertFragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec3 uTransparentColor;
        uniform sampler2D uAtlas;
        uniform vec2 uAtlasSize;
        uniform vec4 uTileUV;
        void main () {
            vec2 uv_ = uv;
            vec2 pixel = (floor(uv_) + 0.5) / uAtlasSize;
            gl_FragColor = texture2D(uAtlas, pixel);
            gl_FragColor.a *= float(gl_FragColor.rgb != uTransparentColor);
            gl_FragColor.a *= float(uv.y < uTileUV.y + uTileUV.w); //cut last top fragment on to - some bugs appiers..
            gl_FragColor.rgb = vec3 (1.,1.,1.) - gl_FragColor.rgb;
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


mainFragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
//        uniform float px;
        uniform vec3 uTransparentColor;
        uniform sampler2D uAtlas;
        uniform vec2 uAtlasSize;
        uniform vec4 uTileUV;
//         mat2 rotate2d(float _angle){
//                    return mat2(cos(_angle),-sin(_angle),
//                                sin(_angle),cos(_angle));
//             }
        void main () {
            vec2 uv_ = uv;
//            vec2 uTileSize = vec2(32., 32.);
//            vec2 fragmentOffsetPx = mod(uv_, uTileSize);
//                        fragmentOffsetPx -= uTileSize * 0.5;
//                        fragmentOffsetPx *= rotate2d(0.5708);
//                        fragmentOffsetPx += uTileSize * 0.5;
//            uv_ = floor(uv_ / uTileSize) * uTileSize + fragmentOffsetPx;
            vec2 pixel = (floor(uv_) + 0.5) / uAtlasSize;



            gl_FragColor = texture2D(uAtlas, pixel);
            gl_FragColor.a *= float(gl_FragColor.rgb != uTransparentColor);
            gl_FragColor.a *= float(uv.y < uTileUV.y + uTileUV.w); //cut last top fragment on to - some bugs appiers..
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]



--https://thebookofshaders.com/08/
--         mat2 rotate2d(float _angle){
--                return mat2(cos(_angle),-sin(_angle),
--                            sin(_angle),cos(_angle));
--         }
--         fragmentOffsetPx *= rotate2d(1.5708);


fragmentShader : Shader {} (Model a) { uv : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform vec3 uTransparentColor;
        uniform sampler2D uAtlas;
        uniform vec2 uAtlasSize;
        uniform vec2 uTileSize;
        uniform vec2 uMirror;
        uniform float uIndex;

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
//         mat2 rotate2d(float _angle){
//                    return mat2(cos(_angle),-sin(_angle),
//                                sin(_angle),cos(_angle));
//             }

        void main () {
            vec2 point = uv;
            vec2 grid = uAtlasSize / uTileSize;
            vec2 tile = vec2(modI((uIndex), grid.x), int(uIndex) / int(grid.x));

            // inverting reading botom to top
            tile.y = grid.y - tile.y - 1.;
            vec2 fragmentOffsetPx = floor((point) * uTileSize);



            fragmentOffsetPx.x = abs(((uTileSize.x - 1.) * uMirror.x ) - fragmentOffsetPx.x);
            fragmentOffsetPx.y = abs(((uTileSize.y - 1.)  * uMirror.y ) - fragmentOffsetPx.y);

//            fragmentOffsetPx -= uTileSize * 0.5;
//            fragmentOffsetPx *= rotate2d(0.5708);
//            fragmentOffsetPx += uTileSize * 0.5;
            //(2i + 1)/(2N) Pixel center
            vec2 pixel = (floor(tile * uTileSize + fragmentOffsetPx) + 0.5) / uAtlasSize;

            gl_FragColor = texture2D(uAtlas, pixel);
            gl_FragColor.a *= float(gl_FragColor.rgb != uTransparentColor);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]
