module Logic.Template.Internal exposing (Plate, Points(..), fullscreenVertexShader, get, plate, points, pxToScreen, remap, tileVertexShader)

import AltMath.Vector2 as Vec2 exposing (Vec2)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vector2
import WebGL exposing (Mesh, Shader)


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


tileVertexShader :
    Shader
        { a
            | position : Vector2.Vec2
        }
        { b
            | height : Float
            , scrollRatio : Vector2.Vec2
            , offset : Vector2.Vec2
            , width : Float
            , viewport : Mat4

            --            , absolute : Mat4
            , x : Float
            , y : Float
        }
        { uv : Vector2.Vec2 }
tileVertexShader =
    [glsl|
        precision mediump float;
        attribute vec2 position;
        uniform float x;
        uniform float y;
        uniform float height;
        uniform float width;
        uniform vec2 offset;
        uniform vec2 scrollRatio;
        varying vec2 uv;
        uniform mat4 viewport;
//        uniform mat4 absolute;

        void main () {
            float aspectRatio = 2.0 / viewport[0][0]; // Mat4.makeOrtho2D
            uv = position;
            vec2 sized = vec2(position * vec2(width, height ));
            vec2 move = vec2(
                (x - offset.x * scrollRatio.x - width / 2.) ,
                (y - offset.y * scrollRatio.y - height / 2.)
            );

            gl_Position = viewport * vec4(sized + move, 0, 1.0);
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
    = Nonempty a (List a)


points : Vec2 -> List Vec2 -> Points
points first rest =
    Points (Nonempty first rest)


get : Int -> Nonempty a -> a
get i ((Nonempty x xs) as ne) =
    let
        j =
            modBy (List.length xs + 1) i

        find k ys =
            case ys of
                [] ->
                    {- This should never happen, but to avoid Debug.crash,
                       we return the head of the list.
                    -}
                    x

                z :: zs ->
                    if k == 0 then
                        z

                    else
                        find (k - 1) zs
    in
    if j == 0 then
        x

    else
        find (j - 1) xs
