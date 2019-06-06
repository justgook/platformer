module Logic.Template.Component.FX exposing (FX, spec)

import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.System exposing (System)
import Logic.Template.Internal exposing (tileVertexShader)
import Logic.Template.Sprite
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import WebGL
import WebGL.Texture exposing (Texture)


type alias FX =
    { fullscreen : List FullScreen
    , emmiter : List ()
    }


type FullScreen
    = Blink
    | Fade


spec : Singleton.Spec FX { world | fx : FX }
spec =
    { get = .fx
    , set = \comps world -> { world | fx = comps }
    }


system : Singleton.Spec FX world -> System world
system spec_ =
    Singleton.update spec_ identity


draw : FX -> List WebGL.Entity
draw fX =
    []


empty : FX
empty =
    { fullscreen = []
    , emmiter = []
    }
