module Logic.Entity exposing
    ( EntityID, create, with
    , fromList, toList
    , fromDict, toDict
    , get, get2, removeFor, update
    )

{-|

@docs EntityID, create, with


# List

@docs fromList, toList


# Dict

@docs fromDict, toDict


# Manipulations

@docs get, get2, removeFor, update

-}

import Array
import Dict exposing (Dict)
import Logic.Component as Component
import Logic.Internal exposing (indexedFoldlArray)


{-| -}
type alias EntityID =
    Int


type alias ComponentSpec comp world =
    Component.Spec comp world


{-| Start point for spawning entity

    Entity.create id world
        |> Entity.with ( positionSpec, positionComponent )
        |> Entity.with ( velocitySpec, velocityComponent )

-}
create : EntityID -> world -> ( EntityID, world )
create id world =
    ( id, world )


{-| Way to create `Entity` destruction functions, should pipe in all possible component sets, from what `Entity` should be removed.
Also can be used to just disable (remove) some components from entity

    remove =
        Entity.removeFor positionSpec
            >> Entity.removeFor velocitySpec

    newWorld =
        remove ( id, world )

-}
removeFor : ComponentSpec comp world -> ( EntityID, world ) -> ( EntityID, world )
removeFor spec ( entityID, world ) =
    ( entityID, spec.set (Array.set entityID Nothing (spec.get world)) world )


{-| Setting components to spawn with new entity

    Entity.create ( id, world )
        |> Entity.with ( positionSpec, positionComponent )
        |> Entity.with ( velocitySpec, velocityComponent )

-}
with : ( ComponentSpec comp world, comp ) -> ( EntityID, world ) -> ( EntityID, world )
with ( spec, component ) ( entityID, world ) =
    let
        updatedComponents =
            spec.get world
                |> Component.spawn entityID component

        updatedWorld =
            spec.set updatedComponents world
    in
    ( entityID, updatedWorld )


{-| Component for Entity by id
-}
get : EntityID -> Component.Set comp -> Maybe comp
get i =
    Array.get i >> Maybe.withDefault Nothing


{-| Components Tuple for Entity by id
-}
get2 : EntityID -> Component.Set comp -> Component.Set comp2 -> Maybe ( comp, comp2 )
get2 i set1 set2 =
    Maybe.map2 Tuple.pair
        (get i set1)
        (get i set2)


{-| Update Component by EntityID
-}
update : EntityID -> (comp -> comp) -> Component.Set comp -> Component.Set comp
update i f =
    Logic.Internal.update i (Maybe.map f)


{-| -}
fromList : List ( EntityID, a ) -> Component.Set a
fromList =
    List.foldl (\( index, value ) components -> Component.spawn index value components) Component.empty


{-| -}
fromDict : Dict EntityID a -> Component.Set a
fromDict =
    Dict.foldl (\index value components -> Component.spawn index value components) Component.empty


{-| -}
toDict : Component.Set a -> Dict EntityID a
toDict =
    indexedFoldlArray (\i a acc -> Maybe.map (\a_ -> Dict.insert i a_ acc) a |> Maybe.withDefault acc) Dict.empty


{-| -}
toList : Component.Set a -> List ( EntityID, a )
toList =
    indexedFoldlArray (\i a acc -> Maybe.map (\a_ -> ( i, a_ ) :: acc) a |> Maybe.withDefault acc) []
