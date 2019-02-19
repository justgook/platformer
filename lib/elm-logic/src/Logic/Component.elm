module Logic.Component exposing (Set, Spec, empty, first, second)

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


first : Spec comp world -> Spec comp ( world, b )
first { get, set } =
    { get = Tuple.first >> get
    , set = \comps ( world, rest ) -> ( set comps world, rest )
    }


second : Spec comp world -> Spec comp ( a, world )
second { get, set } =
    { get = Tuple.second >> get
    , set = \comps ( rest, world ) -> ( rest, set comps world )
    }
