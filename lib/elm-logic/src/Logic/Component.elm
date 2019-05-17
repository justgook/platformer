module Logic.Component exposing (Set, SingletonSpec, Spec, empty, get, mapById, update, updateById)

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


update : { get : world -> comp, set : comp -> world -> world } -> (comp -> comp) -> world -> world
update spec f world =
    spec.set (f (spec.get world)) world


updateById : (Maybe comp -> Maybe comp) -> Int -> Set comp -> Set comp
updateById f i comps =
    Array.set i (f (get i comps)) comps


mapById : (comp -> comp) -> Int -> Set comp -> Set comp
mapById f i comps =
    Array.set i (get i comps |> Maybe.map f) comps


empty : Set comp
empty =
    Array.empty


get : Int -> Set comp -> Maybe comp
get i =
    Array.get i >> Maybe.withDefault Nothing
