module Logic.Component exposing (Set, Spec, empty)

{-|

@docs Set, Spec, empty

-}

import Array exposing (Array)


{-| Component storage, main building block of world
-}
type alias Set comp =
    Array (Maybe comp)


{-| Component specification, how to get `Component.Set` from and world, and set back into world (used by Systems)
-}
type alias Spec comp world =
    { get : world -> Set comp
    , set : Set comp -> world -> world
    }


{-| Initial value of any empty `Component.Set` - mostly used to init component sets in world
-}
empty : Set comp
empty =
    Array.empty
