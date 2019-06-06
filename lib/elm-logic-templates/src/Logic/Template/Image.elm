module Logic.Template.Image exposing (Model, draw, drawNo, drawX, drawY)

--import Logic.Template.Component.Layer.Common exposing (vertexShader)

import Logic.Template.Internal exposing (Plate, entitySettings, plate)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)


type alias Model a =
    { a
        | px : Float
        , offset : Vec2
        , uTransparentColor : Vec3
        , image : Texture
        , size : Vec2
    }



--https://en.wikipedia.org/wiki/Moir%C3%A9_pattern
--https://www.youtube.com/watch?v=aMcJ1Jvtef0 -- Way to add snow / rain
--http://effectgames.com/demos/worlds/


drawX : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
drawX =
    render_ fragmentShaderRepeatX


drawY : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
drawY =
    render_ fragmentShaderRepeatY


drawNo : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
drawNo =
    render_ fragmentShaderNoRepeat


draw : WebGL.Shader Plate (Model a) { uv : Vec2 } -> Model a -> WebGL.Entity
draw =
    render_ fragmentShaderRepeat


render_ :
    Shader {} (Model a) { uv : Vec2 }
    -> Shader Plate (Model a) { uv : Vec2 }
    -> Model a
    -> WebGL.Entity
render_ fragmentShader vertexShader =
    WebGL.entityWith
        entitySettings
        vertexShader
        fragmentShader
        plate


fragmentShaderRepeat : Shader {} (Model a) { uv : Vec2 }
fragmentShaderRepeat =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform sampler2D image;
        uniform vec3 uTransparentColor;
        uniform float px;
        uniform vec2 offset;
//        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
//            vec2 pixel = (floor(uv * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            vec2 pixel = (floor(uv / px
//            + viewportOffset * scrollRatio
            ) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


fragmentShaderRepeatX : Shader {} (Model a) { uv : Vec2 }
fragmentShaderRepeatX =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform sampler2D image;
        uniform vec3 uTransparentColor;
        uniform float px;
        uniform vec2 offset;
//        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
//            vec2 pixel = (floor(uv * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            vec2 pixel = (floor(uv / px
//            + viewportOffset * scrollRatio
            ) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.a *= float(pixel.y <= 1.0);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


fragmentShaderRepeatY : Shader {} (Model a) { uv : Vec2 }
fragmentShaderRepeatY =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform sampler2D image;
        uniform vec3 uTransparentColor;
        uniform float px;
        uniform vec2 offset;
//        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
//            vec2 pixel = (floor(uv * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            vec2 pixel = (floor(uv / px
//            + viewportOffset * scrollRatio
            ) + 0.5 ) / size;
            gl_FragColor = texture2D(image, mod(pixel, 1.0));
            gl_FragColor.a *= float(pixel.x <= 1.0);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]


fragmentShaderNoRepeat : Shader {} (Model a) { uv : Vec2 }
fragmentShaderNoRepeat =
    [glsl|
        precision mediump float;
        varying vec2 uv;
        uniform sampler2D image;
        uniform vec3 uTransparentColor;
        uniform float px;
        uniform vec2 offset;
//        uniform vec2 scrollRatio;
        uniform vec2 size;

        void main () {
            //(2i + 1)/(2N) Pixel center
//            vec2 pixel = (floor(uv * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;
            vec2 pixel = (floor(uv / px
//            + viewportOffset * scrollRatio
            ) + 0.5 ) / size;
            gl_FragColor = texture2D(image, pixel);
            gl_FragColor.a *= float(pixel.x <= 1.0) * float(pixel.y <= 1.0);
            gl_FragColor.rgb *= gl_FragColor.a;
        }
    |]
