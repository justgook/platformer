module Logic.Asset.Input exposing (Component, Direction, empty, spec)

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
    { get = .direction >> .comps
    , set =
        \comps world ->
            let
                dir =
                    world.direction
            in
            { world | direction = { dir | comps = comps } }
    }
