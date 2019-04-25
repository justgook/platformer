module Logic.Entity exposing (EntityID, create, fromDict, fromList, setComponent, toDict, with)

import Array
import Dict exposing (Dict)
import Logic.Component as Component
import Logic.Internal exposing (indexedFoldlArray)


{-| -}
type alias EntityID =
    Int


create : Int -> world -> ( EntityID, world )
create id world =
    ( id, world )


with : ( Component.Spec comp world, comp ) -> ( EntityID, world ) -> ( EntityID, world )
with ( { get, set }, component ) ( mId, world ) =
    let
        updatedComponents =
            get world
                |> setComponent mId component

        updatedWorld =
            set updatedComponents world
    in
    ( mId, updatedWorld )


setComponent : EntityID -> a -> Component.Set a -> Component.Set a
setComponent index value components =
    if index - Array.length components < 0 then
        Array.set index (Just value) components

    else
        Array.append components (Array.repeat (index - Array.length components) Nothing)
            |> Array.push (Just value)


fromList : List ( EntityID, a ) -> Component.Set a
fromList =
    List.foldl (\( index, value ) components -> setComponent index value components) Component.empty


fromDict : Dict EntityID a -> Component.Set a
fromDict =
    Dict.foldl (\index value components -> setComponent index value components) Component.empty


toDict : Component.Set a -> Dict EntityID a
toDict =
    indexedFoldlArray (\i a acc -> Maybe.map (\a_ -> Dict.insert i a_ acc) a |> Maybe.withDefault acc) Dict.empty
