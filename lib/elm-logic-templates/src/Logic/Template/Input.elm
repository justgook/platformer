module Logic.Template.Input exposing (Direction, Input, empty, emptyComp, getComps, spec)

import Dict exposing (Dict)
import Logic.Component exposing (Set, Spec)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Set


type alias Input =
    { x : Float
    , y : Float
    , down : String
    , left : String
    , right : String
    , up : String
    , action : Set.Set String
    }


type alias Direction =
    { comps : Logic.Component.Set Input
    , registered : Dict String ( EntityID, String )
    , pressed : Set.Set String
    }


emptyComp : Input
emptyComp =
    { x = 0
    , y = 0
    , down = ""
    , left = ""
    , right = ""
    , up = ""
    , action = Set.empty
    }


empty : Direction
empty =
    { pressed = Set.empty
    , comps = Logic.Component.empty
    , registered = Dict.empty
    }


spec : Singleton.Spec Direction { world | input : Direction }
spec =
    { get = .input
    , set = \comps world -> { world | input = comps }
    }


getComps spec_ =
    { get = spec_.get >> .comps
    , set =
        \comps world ->
            let
                dir =
                    spec_.get world
            in
            spec_.set { dir | comps = comps } world
    }
