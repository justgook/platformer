module Logic.Component exposing (Set, Spec, empty)

import Array exposing (Array)


type alias Set comp =
    Array (Maybe comp)


type alias Spec comp world =
    { get : world -> Set comp
    , set : Set comp -> world -> world
    }


empty : Set comp
empty =
    Array.empty
