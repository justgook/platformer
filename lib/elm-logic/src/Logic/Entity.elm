module Logic.Entity exposing (EntityID, create, fromDict, fromList, getComponent, mapComponent, mapComponentSet, removeComponent, removeFor, setComponent, spawnComponent, toDict, toList, with)

import Array
import Dict exposing (Dict)
import Logic.Component as Component
import Logic.Internal exposing (indexedFoldlArray)


{-| -}
type alias EntityID =
    Int


create : EntityID -> world -> ( EntityID, world )
create id world =
    ( id, world )


removeComponent : EntityID -> Component.Set a -> Component.Set a
removeComponent entityID components =
    Array.set entityID Nothing components


removeFor : Component.Spec comp world -> ( EntityID, world ) -> ( EntityID, world )
removeFor spec ( entityID, world ) =
    ( entityID, spec.set (Array.set entityID Nothing (spec.get world)) world )


with : ( Component.Spec comp world, comp ) -> ( EntityID, world ) -> ( EntityID, world )
with ( { get, set }, component ) ( entityID, world ) =
    let
        updatedComponents =
            get world
                |> spawnComponent entityID component

        updatedWorld =
            set updatedComponents world
    in
    ( entityID, updatedWorld )


spawnComponent : EntityID -> a -> Component.Set a -> Component.Set a
spawnComponent index value components =
    if index - Array.length components < 0 then
        Array.set index (Just value) components

    else
        Array.append components (Array.repeat (index - Array.length components) Nothing)
            |> Array.push (Just value)


{-| Set the component at a particular index. Returns an updated component Set. If the index is out of range, the Set is unaltered.
-}
setComponent : EntityID -> a -> Component.Set a -> Component.Set a
setComponent index value components =
    Array.set index (Just value) components


getComponent : Int -> Component.Set comp -> Maybe comp
getComponent i =
    Array.get i >> Maybe.withDefault Nothing


mapComponent : (Maybe comp -> Maybe comp) -> EntityID -> Component.Set comp -> Component.Set comp
mapComponent f i comps =
    Array.set i (f (getComponent i comps)) comps


mapComponentSet : (comp -> comp) -> EntityID -> Component.Set comp -> Component.Set comp
mapComponentSet f i comps =
    Array.set i (getComponent i comps |> Maybe.map f) comps


fromList : List ( EntityID, a ) -> Component.Set a
fromList =
    List.foldl (\( index, value ) components -> spawnComponent index value components) Component.empty


fromDict : Dict EntityID a -> Component.Set a
fromDict =
    Dict.foldl (\index value components -> spawnComponent index value components) Component.empty


toDict : Component.Set a -> Dict EntityID a
toDict =
    indexedFoldlArray (\i a acc -> Maybe.map (\a_ -> Dict.insert i a_ acc) a |> Maybe.withDefault acc) Dict.empty


toList : Component.Set a -> List ( EntityID, a )
toList =
    indexedFoldlArray (\i a acc -> Maybe.map (\a_ -> ( i, a_ ) :: acc) a |> Maybe.withDefault acc) []
