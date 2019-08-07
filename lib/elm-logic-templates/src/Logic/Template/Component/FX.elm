module Logic.Template.Component.FX exposing (FX, draw, empty, get, invertColors, shake, spec, system)

import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.System as System exposing (System)
import Logic.Template.Component.Sprite as SpriteComponent
import Logic.Template.Internal exposing (tileVertexShader)
import Logic.Template.RenderInfo as RenderInfo
import Logic.Template.Sprite
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL
import WebGL.Texture exposing (Texture)


type alias FX =
    { fullscreen : List FullScreen
    , components : Component.Set Entity
    }


type alias Life =
    Int


type Entity
    = InvertColors Life


type FullScreen
    = Blink Life
    | Fade Life
    | Shake Life
    | Sprite Life SpriteComponent.Sprite


spec : Singleton.Spec FX { world | fx : FX }
spec =
    { get = .fx
    , set = \comps world -> { world | fx = comps }
    }


system : Singleton.Spec FX world -> System world
system spec_ =
    Singleton.update spec_
        (\store ->
            { store
                | fullscreen = List.filterMap lifeSpanFullscreen store.fullscreen
                , components = System.filterMap lifeSpanComponents store.components
            }
        )


shake spec_ =
    Singleton.update spec_ (\comp -> { comp | fullscreen = Shake 10 :: comp.fullscreen })


get spec_ i w =
    Entity.get i (spec_.get w |> .components)


invertColors spec_ i =
    Singleton.update spec_
        (\store ->
            { store
                | components =
                    Component.spawn i (InvertColors 2) store.components
            }
        )


lifeSpanComponents item =
    case item of
        InvertColors i ->
            reduceOrNothing InvertColors i


lifeSpanFullscreen item =
    case item of
        Blink i ->
            reduceOrNothing Blink i

        Fade i ->
            reduceOrNothing Fade i

        Shake i ->
            reduceOrNothing Shake i

        Sprite i sprite ->
            reduceOrNothing (\i_ -> Sprite i_ sprite) i


reduceOrNothing f i =
    if i - 1 <= 0 then
        Nothing

    else
        f (i - 1)
            |> Just


apply item ( w, layers ) =
    case item of
        Blink i ->
            ( w, layers )

        Fade i ->
            ( w, layers )

        Shake i ->
            let
                xShake =
                    toFloat i |> (*) 5 |> sin |> (*) 3
            in
            ( { w | render = RenderInfo.updateOffsetX xShake w.render }, [] )

        Sprite i sprite ->
            ( w, layers )



--draw : Singleton.Spec FX world -> world -> ( world, List WebGL.Entity )


draw spec_ w =
    let
        items =
            spec_.get w
                |> .fullscreen
    in
    List.foldl apply ( w, [] ) items


empty : FX
empty =
    { fullscreen = []
    , components = Component.empty
    }
