module Logic.Component exposing (Set, SingletonSpec, Spec, empty, get)

import Array exposing (Array)


type alias Set comp =
    Array (Maybe comp)


type alias Spec comp world =
    { get : world -> Set comp
    , set : Set comp -> world -> world
    }


type alias SingletonSpec comp world =
    { get : world -> comp
    , set : comp -> world -> world
    }


empty : Set comp
empty =
    Array.empty


get : Int -> Set comp -> Maybe comp
get i =
    Array.get i >> Maybe.withDefault Nothing
