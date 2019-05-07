[![Build Status](https://travis-ci.org/justgook/elm-image-encode.svg?branch=master)](https://travis-ci.org/justgook/elm-image-encode)

A library for building base64 encoded images in elm

## Motivation

[WebGL for Elm](http://package.elm-lang.org/packages/elm-community/webgl/latest) do not support arrays, so I need to build lookup tables for that, to prevent doing it in preprocess was created this library that can convert matrix into image, and then used in shader.


## Examples

```elm

import Html exposing (img)
    import Html.Attributes exposing (src)
    import Image exposing (ColorDepth, Options)
    import Image.BMP exposing (encode24With)

    main : Html.Html msg
    main =
        img [ src (encode24With width height pixels options) ] []

    width : Int
    width =
        2

    height : Int
    height =
        2

    red : Int
    red =
        0x00FF0000

    green : Int
    green =
        0xFF00

    blue : Int
    blue =
        0xFF

    pixels : List Int
    pixels =
        [ red, green, blue, red ]

    options : Options {}
    options =
        { defaultColor = 0x00FFFF00, order = RightDown, depth = Bit24 }

```

## Example 2

Create texture useing base64 encoded image and load it to  shader
```elm
import Image.BMP exposing (encode24)

textureTask = WebGL.Texture.load (encode24 2 2 [1,2,3,4] )
-- then use resulting texture as lookup table
```

You can use simple function to get data from lookup table, where `color` is pixel color from just created texture
```glsl
float color2float(vec4 color) {
    return color.z * 255.0
    + color.y * 256.0 * 255.0
    + color.x * 256.0 * 256.0 * 255.0
    ;
}
```
