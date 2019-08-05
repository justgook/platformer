module Logic.Component exposing (Set, Spec, empty, remove, set, spawn)

{-|

@docs Set, Spec, empty, remove, set, spawn

-}

import Array exposing (Array)


{-| Component storage, main building block of world
-}
type alias Set comp =
    Array (Maybe comp)


type alias EntityID =
    Int


{-| Component specification, how to get `Component.Set` from world and set back into world (mainly used by Systems)
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


{-| Remove component from `ComponentSet` by `EntityID` return new `ComponentSet`, or return unchanged if component not in set
-}
remove : EntityID -> Set a -> Set a
remove entityID components =
    Array.set entityID Nothing components


{-| Safe way to create component, same as setComponent, only if index is out of range ComponentSet will be stretched
-}
spawn : EntityID -> a -> Set a -> Set a
spawn index value components =
    if index - Array.length components < 0 then
        Array.set index (Just value) components

    else
        Array.append components (Array.repeat (index - Array.length components) Nothing)
            |> Array.push (Just value)


{-| Set the component at a particular index. Returns an updated component Set. If the index is out of range, the Set is unaltered.
-}
set : EntityID -> a -> Set a -> Set a
set index value components =
    Array.set index (Just value) components
