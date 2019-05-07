module Logic.Asset.AnimationDict exposing (Animation, AnimationDict, empty, spec)

import Dict exposing (Dict)
import Logic.Component
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


spec =
    { get = .animations
    , set = \comps world -> { world | animations = comps }
    }


empty =
    Logic.Component.empty
