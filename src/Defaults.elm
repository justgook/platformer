module Defaults exposing (default)

import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL
import WebGL.Texture as Texture exposing (Texture, linear, nearest, nonPowerOfTwoOptions)


default =
    { pixelsPerUnit = 10
    , viewportOffset = vec2 0 0
    , transparentcolor = vec3 0 0 0
    , scrollRatio = 1
    , webGLOption = webGLOption
    , textureOption = textureOption
    }


webGLOption : List WebGL.Option
webGLOption =
    [ WebGL.alpha False
    , WebGL.depth 1
    , WebGL.clearColor 0 0 0 1
    ]


textureOption : Texture.Options
textureOption =
    { nonPowerOfTwoOptions
        | magnify = nearest
        , minify = linear
    }
