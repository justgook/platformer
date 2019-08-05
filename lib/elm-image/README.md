[![Build Status](https://travis-ci.org/justgook/elm-image.svg?branch=master)](https://travis-ci.org/justgook/elm-image)

A library for building base64 encoded images in elm

## Motivation

[WebGL for Elm](http://package.elm-lang.org/packages/elm-community/webgl/latest) do not support arrays, so I need to build lookup tables for that, to prevent doing it in preprocess was created this library that can convert matrix into image, and then used in shader.


## Examples

```elm
import Base64
import Html exposing (img)
import Html.Attributes exposing (src)
import Image
import Image.Data as Image exposing (Image)
import Image.Options

main =
    let
        imageData : Image
        imageData =
            Image.fromList2d
                [ List.repeat 4 0xFFFF
                , List.repeat 4 0xFF0000FF
                , List.repeat 4 0xFFFF
                , List.repeat 2 0x00FFFFFF
                ]

        pngEncodeBase64 =
            imageData
                |> Image.encodePng
                |> Base64.fromBytes
                |> Maybe.withDefault ""
    in
    img [ src ("data:image/png;base64," ++ pngEncodeBase64) ] []
```

## Example 2

Create texture useing base64 encoded image and load it to  shader
```elm
textureTask = WebGL.Texture.load ("data:image/png;base64," ++ pngEncodeBase64)
-- then use resulting texture as lookup table
```

You can use simple function to get data from lookup table, where `color` is pixel color from just created texture
```glsl
float color2float(vec4 color) {
    return
    color.a * 255.0
    + color.b * 256.0 * 255.0
    + color.g * 256.0 * 256.0 * 255.0
    + color.r * 256.0 * 256.0 * 256.0 * 255.0;
    }
```
