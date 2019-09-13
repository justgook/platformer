module Tiled.NestedProperties exposing (Property(..), at, convert, get, toList, values)

import Dict exposing (Dict)
import Tiled.Properties


{-| Custom properties values
-}
type Property
    = PropBool Bool
    | PropInt Int
    | PropFloat Float
    | PropString String
    | PropColor String
    | PropFile String
    | PropCollection (Dict String Property)


convert : Tiled.Properties.Properties -> Property
convert props =
    props
        |> Dict.toList
        |> digIn Dict.empty


get : String -> Property -> Maybe Property
get k prop =
    case prop of
        PropCollection dict ->
            Dict.get k dict

        _ ->
            Nothing


at : List String -> Property -> Maybe Property
at l prop =
    case ( l, prop ) of
        ( k :: rest, PropCollection dict ) ->
            Dict.get k dict
                |> Maybe.andThen (at rest)

        ( [], v ) ->
            Just v

        _ ->
            Nothing


values : Property -> List Property
values property =
    case property of
        PropCollection dict ->
            Dict.values dict

        p ->
            [ p ]


toList : Property -> List ( String, Property )
toList property =
    case property of
        PropCollection dict ->
            Dict.toList dict

        p ->
            [ ( "", p ) ]


digIn : Dict String Property -> List ( String, Tiled.Properties.Property ) -> Property
digIn acc list =
    case list of
        ( key, value ) :: rest ->
            let
                crumbs =
                    String.replace "[" "." key
                        |> String.replace "]" "."
                        |> String.replace ".." "."
                        |> (\a -> applyIf (String.endsWith "." a) (String.dropRight 1) a)
                        |> String.split "."
            in
            digIn (updateCrumbsInt crumbs value acc) rest

        [] ->
            PropCollection acc


updateCrumbsInt : List String -> Tiled.Properties.Property -> Dict String Property -> Dict String Property
updateCrumbsInt crumbs val props =
    case crumbs of
        [] ->
            props

        x :: [] ->
            Dict.insert x (prop2Prop val) props

        x :: xs ->
            let
                oldProps =
                    case Dict.get x props of
                        Just (PropCollection currentProps) ->
                            currentProps

                        _ ->
                            Dict.empty
            in
            Dict.insert x (PropCollection (updateCrumbsInt xs val oldProps)) props


prop2Prop v_ =
    case v_ of
        Tiled.Properties.PropBool v ->
            PropBool v

        Tiled.Properties.PropInt v ->
            PropInt v

        Tiled.Properties.PropFloat v ->
            PropFloat v

        Tiled.Properties.PropString v ->
            PropString v

        Tiled.Properties.PropColor v ->
            PropColor v

        Tiled.Properties.PropFile v ->
            PropFile v


{-| -}
applyIf : Bool -> (a -> a) -> a -> a
applyIf bool f world =
    if bool then
        f world

    else
        world
