module Logic.Entity exposing (EntityID, create, with)

import Array
import Logic.Component as Component


{-| -}
type alias EntityID =
    Int


create : Int -> world -> ( EntityID, world )
create id world =
    ( id, world )


with : ( Component.Spec comp world, comp ) -> ( EntityID, world ) -> ( EntityID, world )
with ( { get, set }, component ) ( mid, world ) =
    let
        updatedComponents =
            get world
                |> setComponent mid component

        updatedWorld =
            set updatedComponents world
    in
    ( mid, updatedWorld )


setComponent : EntityID -> a -> Component.Set a -> Component.Set a
setComponent index value components =
    if index - Array.length components < 0 then
        Array.set index (Just value) components

    else
        Array.append components (Array.repeat (index - Array.length components) Nothing)
            |> Array.push (Just value)
