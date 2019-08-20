module Logic.Template.Component.Ammo exposing (Ammo, Template, Template_, add, empty, emptyComp, fromList, get, set, spec, toList)

import AltMath.Vector2 exposing (Vec2)
import Dict exposing (Dict)
import Logic.Component exposing (Set, Spec)
import Logic.Template.Component.Sprite exposing (Sprite)


type Ammo
    = Empty
    | Ammo ( String, Templates ) (Dict String Templates)


type alias Templates =
    List Template


type alias Template =
    Template_ {}


type alias Template_ a =
    { a
        | sprite : Sprite
        , offset : Vec2
        , velocity : Vec2
        , fireRate : Int
        , damage : Int
    }


spec : Spec Ammo { world | ammo : Set Ammo }
spec =
    { get = .ammo
    , set = \comps world -> { world | ammo = comps }
    }


empty : Set Ammo
empty =
    Logic.Component.empty


emptyComp : Ammo
emptyComp =
    Empty


add : String -> Template -> Ammo -> Ammo
add name template ammo_ =
    case ammo_ of
        Empty ->
            Ammo ( name, [ template ] ) (Dict.fromList [ ( name, [ template ] ) ])

        Ammo ( curName, current ) ammo ->
            let
                newCurrent =
                    if name == curName then
                        ( curName, template :: current )

                    else
                        ( curName, current )
            in
            Dict.update name
                (\value ->
                    case value of
                        Just items ->
                            Just (template :: items)

                        Nothing ->
                            Just [ template ]
                )
                ammo
                |> Ammo newCurrent


get : Ammo -> Maybe Templates
get ammo_ =
    case ammo_ of
        Empty ->
            Nothing

        Ammo ( _, current ) _ ->
            Just current


set : String -> Ammo -> Ammo
set newName ammo_ =
    case ammo_ of
        Empty ->
            Empty

        Ammo ( name, _ ) rest ->
            if newName == name then
                ammo_

            else
                case Dict.get newName rest of
                    Just item ->
                        Ammo ( newName, item ) rest

                    Nothing ->
                        ammo_


fromList : List ( String, Templates ) -> Ammo
fromList l =
    case l of
        ( name, templates ) :: _ ->
            Ammo ( name, templates ) (Dict.fromList l)

        [] ->
            Empty


toList : Ammo -> List ( String, Templates )
toList ammo_ =
    case ammo_ of
        Ammo _ ammo ->
            Dict.toList ammo

        Empty ->
            []
