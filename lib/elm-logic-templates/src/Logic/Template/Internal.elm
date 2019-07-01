module Logic.Template.Internal exposing
    ( FullScreenVertexShaderModel
    , Plate
    , Points(..)
    , TileVertexShaderModel
    , Timeline
    , clipPlate
    , entitySettings
    , fullscreenVertexShader
    , get
    , plate
    ,  points
       --    , pxToScreen

    , remap
    , tileVertexShader
    , tileVertexShader2
    , timeline
    , toList
    )

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Array exposing (Array)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vector2
import WebGL exposing (Mesh, Shader)
import WebGL.Settings as WebGL exposing (Setting)
import WebGL.Settings.Blend as Blend


entitySettings : List Setting
entitySettings =
    [ WebGL.cullFace WebGL.front
    , Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha
    , WebGL.colorMask True True True False
    ]


plate : Mesh Plate
plate =
    WebGL.triangleStrip
        [ Plate (Vector2.vec2 0 1)
        , Plate (Vector2.vec2 1 1)
        , Plate (Vector2.vec2 0 0)
        , Plate (Vector2.vec2 1 0)
        ]


clipPlate : Mesh Plate
clipPlate =
    WebGL.triangleStrip
        [ Plate (Vector2.vec2 -1 -1)
        , Plate (Vector2.vec2 -1 1)
        , Plate (Vector2.vec2 1 -1)
        , Plate (Vector2.vec2 1 1)
        ]


type alias Plate =
    { aP : Vector2.Vec2 }


type alias TileVertexShaderModel a =
    { a | uDimension : Vector2.Vec2, uAbsolute : Mat4, uP : Vector2.Vec2 }


type alias FullScreenVertexShaderModel a =
    { a | viewport : Mat4, offset : Vector2.Vec2 }


tileVertexShader : Shader Plate (TileVertexShaderModel a) { uv : Vector2.Vec2 }
tileVertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 aP;
        uniform vec2 uDimension;
        varying vec2 uv;
        uniform mat4 uAbsolute;
        uniform vec2 uP;
        void main () {
            uv = aP;
            vec2 sized = vec2(aP * uDimension);
            vec2 center = uDimension * 0.5;
            gl_Position = uAbsolute * vec4(sized + uP - center, 0, 1.0);
        }
    |]


tileVertexShader2 =
    [glsl|
        precision mediump float;
        attribute vec2 aP;
        varying vec2 uv;
        uniform mat4 uAbsolute;
        uniform vec2 uP;
        uniform vec2 uAtlasSize;
        uniform vec4 uTileUV;
        uniform vec2 uMirror;
        uniform float px;
        void main () {
            uv = uTileUV.xy + (aP * uTileUV.zw) * (1. - uMirror * 2.);
            vec2 uDimension = uTileUV.zw * px;
            vec2 sized = vec2(aP * uDimension);
            vec2 uP_ = uP * px;
            gl_Position = uAbsolute * vec4(sized + uP_, 0, 1.0);
        }
    |]


fullscreenVertexShader : Shader Plate (FullScreenVertexShaderModel a) { uv : Vector2.Vec2 }
fullscreenVertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 aP;
        varying vec2 uv;
        uniform mat4 viewport;
        uniform vec2 offset;

        void main () {
          float aspectRatio = 2.0 / viewport[0][0]; // Mat4.makeOrtho2D
          uv = vec2(aP.x * aspectRatio , aP.y);
          vec2 pos = uv;
          uv += offset;
          gl_Position = viewport * vec4(pos, 0, 1.0);
        }
    |]


remap : Float -> Float -> Float -> Float -> Float -> Float
remap start1 stop1 start2 stop2 n =
    let
        newVal =
            (n - start1) / (stop1 - start1) * (stop2 - start2) + start2
    in
    if start2 < stop2 then
        max start2 <| min newVal stop2

    else
        max stop2 <| min newVal start2


type Points
    = Points (Nonempty Vec2)


type Nonempty a
    = Nonempty a (Array a)


type alias Timeline a =
    Nonempty a


timeline : a -> List a -> Timeline a
timeline first rest =
    Nonempty first (Array.fromList rest)


points : Vec2 -> List Vec2 -> Points
points first rest =
    Points (Nonempty first (Array.fromList rest))


get : Int -> Nonempty a -> a
get i (Nonempty x xs) =
    let
        j =
            modBy (Array.length xs + 1) i
    in
    if j == 0 then
        x

    else
        Array.get (j - 1) xs |> Maybe.withDefault x


toList : Nonempty a -> List a
toList (Nonempty a l) =
    a :: Array.toList l
