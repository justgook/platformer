module Logic.Template.Internal exposing (Plate, Points(..), TileVertexShaderModel, entitySettings, fullscreenVertexShader, get, plate, points, pxToScreen, remap, tileVertexShader)

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


pxToScreen : Float -> Vec2 -> Vector2.Vec2
pxToScreen px p =
    Vec2.scale px p
        |> Vector2.fromRecord


plate : Mesh Plate
plate =
    WebGL.triangleStrip
        [ Plate (Vector2.vec2 0 0)
        , Plate (Vector2.vec2 0 1)
        , Plate (Vector2.vec2 1 0)
        , Plate (Vector2.vec2 1 1)
        ]


type alias Plate =
    { position : Vector2.Vec2 }


type alias TileVertexShaderModel a =
    { a | height : Float, width : Float, absolute : Mat4, p : Vector2.Vec2 }


tileVertexShader : Shader Plate (TileVertexShaderModel a) { uv : Vector2.Vec2 }
tileVertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        uniform float height;
        uniform float width;
        varying vec2 uv;
        uniform mat4 absolute;
        uniform vec2 p;
        void main () {
            uv = position;
            vec2 sized = vec2(position * vec2(width, height));
            vec2 center = vec2(width, height) * 0.5;
            gl_Position = absolute * vec4(sized + p - center, 0, 1.0);
        }
    |]


fullscreenVertexShader : Shader Plate { b | viewport : Mat4, offset : Vector2.Vec2 } { uv : Vector2.Vec2 }
fullscreenVertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        varying vec2 uv;
        uniform mat4 viewport;
        uniform vec2 offset;

        void main () {
          float aspectRatio = 2.0 / viewport[0][0]; // Mat4.makeOrtho2D
          uv = vec2(position.x * aspectRatio , position.y);
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
        Array.get (j - 1) xs
            |> Maybe.withDefault x
