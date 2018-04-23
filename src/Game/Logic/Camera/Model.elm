module Game.Logic.Camera.Model exposing (Behavior(..), Model, init, setCenter, setOffset, setWidthRatio)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Slime exposing (EntityID)


type Behavior
    = Static
      --TODO add some kind of function https://youtu.be/pdvCO97jOQk
    | Follow { id : EntityID } --TODO use linear interpolation (lerp smooth)


type CameraEffects
    = Shake { framesLeft : Int }


type alias Model =
    { widthRatio : Float
    , offset : Vec2
    , pixelsPerUnit : Float
    , behavior : Behavior
    }



-- https://stackoverflow.com/questions/8316882/what-is-an-easing-function
-- Math.easeInQuad = function (t, b, c, d) {
-- 	t = t / d;
-- 	return c*t*t + b;
-- };
-- function linear(time, begin, change, duration) {
--     return change * (time / duration) + start;
-- }


setWidthRatio : Float -> Model -> Model
setWidthRatio widthRatio camera =
    { camera | widthRatio = widthRatio }


setOffset : Vec2 -> Model -> Model
setOffset offset camera =
    { camera | offset = offset }


setCenter : Vec2 -> Model -> Model
setCenter center ({ widthRatio, pixelsPerUnit, offset } as camera) =
    let
        half =
            pixelsPerUnit / 2

        newOffset =
            vec2 (widthRatio * half) half |> Vec2.sub center

        lerp =
            -- TODO Change to something more smart
            Vec2.scale 0.1

        newOffset2 =
            Vec2.sub newOffset offset
                |> doIf (lengthLessThan (vec2 0.5 0.5)) lerp
                |> Vec2.add offset
    in
    { camera | offset = newOffset2 }


init : { b | pixelsPerUnit : Float } -> Model
init props =
    { widthRatio = 1
    , offset = vec2 0 0
    , pixelsPerUnit = props.pixelsPerUnit
    , behavior = Static
    }


doIf : (a -> Bool) -> (a -> a) -> a -> a
doIf bool func i =
    if bool i then
        func i
    else
        i


lengthLessThan : Vec2 -> Vec2 -> Bool
lengthLessThan a b =
    Vec2.length a < Vec2.length b


absMaxVec2 : Vec2 -> Vec2 -> Vec2
absMaxVec2 a b =
    if Vec2.length a > Vec2.length b then
        a
    else
        b



-- https://forum.unity.com/threads/screen-shake-effect.22886/
-- https://en.wikipedia.org/wiki/Perlin_noise
-- public AnimationCurve curve;
-- float t=0f;
-- void Update () {
-- //...clever code
-- float shake = Shake( 10f, 2f, shakeCurve);
-- //apply this shake to whatever you want, it's 1d right now but can be easily expanded to 2d
-- }
-- float Shake (float shakeDamper, float shakeTime, AnimationCurve curve) {
-- t += Time.deltaTime;
-- return Mathf.PerlinNoise(t / shakeDamper, 0f) * curve.Eval(t);
-- }
