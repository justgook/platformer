module Logic.Template.Component.TimeLine exposing (Frame, NotSimple, TileUV, empty, emptyComp, get, spec)

import Logic.Component exposing (Set, Spec)
import Logic.Template.Internal.RangeTree as RangeTree exposing (RangeTree(..))
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector4 exposing (Vec4)


spec : Spec NotSimple { world | timelines : Set NotSimple }
spec =
    { get = .timelines
    , set = \comps world -> { world | timelines = comps }
    }


type alias Frame =
    Int


type alias TileUV =
    Vec4


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
