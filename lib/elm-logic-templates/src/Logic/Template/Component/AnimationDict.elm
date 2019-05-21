module Logic.Template.Component.AnimationDict exposing (Animation, AnimationDict, empty, spec)

import Dict exposing (Dict)
import Logic.Component exposing (Set, Spec)
import Math.Vector2 as Vec2 exposing (Vec2)
import WebGL.Texture exposing (Texture)


type alias AnimationDict =
    ( ( String, Int ), Dict ( String, Int ) Animation )


type alias Animation =
    { tileSet : Texture
    , tileSetSize : Vec2
    , tileSize : Vec2
    , mirror : Vec2
    , animLUT : Texture
    , animLength : Int
    }


spec : Spec AnimationDict { world | animations : Set AnimationDict }
spec =
    { get = .animations
    , set = \comps world -> { world | animations = comps }
    }


empty =
    Logic.Component.empty
