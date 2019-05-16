module Logic.Template.Input exposing (Component, Direction, empty, getComps, spec)

import Dict exposing (Dict)
import Logic.Component
import Logic.Entity as Entity exposing (EntityID)
import Set


type alias Component =
    { x : Float
    , y : Float
    , down : String
    , left : String
    , right : String
    , up : String
    }


type alias Direction =
    { comps : Logic.Component.Set Component
    , registered : Dict String EntityID
    , pressed : Set.Set String
    }


empty =
    { pressed = Set.empty
    , comps = Logic.Component.empty
    , registered = Dict.empty
    }


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
