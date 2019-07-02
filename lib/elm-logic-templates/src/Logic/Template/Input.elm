module Logic.Template.Input exposing (Input, InputSingleton, empty, emptyComp, spec, toComps)

import Dict exposing (Dict)
import Logic.Component exposing (Set, Spec)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Set


type alias Input =
    { x : Float
    , y : Float
    , action : Set.Set String
    }


type alias InputSingleton =
    { comps : Logic.Component.Set Input
    , registered : Dict String ( EntityID, String )
    , pressed : Set.Set String
    }


emptyComp : Input
emptyComp =
    { x = 0
    , y = 0
    , action = Set.empty
    }


empty : InputSingleton
empty =
    { pressed = Set.empty
    , comps = Logic.Component.empty
    , registered = Dict.empty
    }


spec : Singleton.Spec InputSingleton { world | input : InputSingleton }
spec =
    { get = .input
    , set = \comps world -> { world | input = comps }
    }


toComps spec_ =
    { get = spec_.get >> .comps
    , set =
        \comps world ->
            let
                dir =
                    spec_.get world
            in
            spec_.set { dir | comps = comps } world
    }
