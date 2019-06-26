module Logic.Template.Component.FrameChange exposing (Frame, NotSimple, empty, emptyComp, get, spec)

import Logic.Component exposing (Set, Spec)
import Logic.Template.Internal.RangeTree as RangeTree exposing (RangeTree(..))
import Logic.Template.SaveLoad.Internal.Util exposing (TileUV)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector4 exposing (Vec4)


spec : Spec NotSimple { world | animation : Set NotSimple }
spec =
    { get = .animation
    , set = \comps world -> { world | animation = comps }
    }


type alias Frame =
    Int


type alias NotSimple =
    { start : Int
    , timeline : RangeTree TileUV
    , uMirror : Vec2
    }


empty : Set NotSimple
empty =
    Logic.Component.empty


emptyComp tree =
    { start = 0
    , timeline = tree
    , uMirror = vec2 0 0
    }


get : Frame -> NotSimple -> TileUV
get frame notSimple =
    case notSimple.timeline of
        Value _ v ->
            v

        Node frame_ _ _ ->
            RangeTree.get (modBy frame_ frame) notSimple.timeline
