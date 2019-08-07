module Logic.Template.Component.Ammo exposing (Ammo, Template, add, empty, emptyComp, get, spec)

import AltMath.Vector2 exposing (Vec2)
import Dict exposing (Dict)
import Logic.Component exposing (Set, Spec)
import Logic.Template.Component.Sprite exposing (Sprite)


type alias Ammo =
    Dict String Templates


type alias Templates =
    List Template


type alias Template =
    { sprite : Sprite
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
    Dict.empty


add : String -> Template -> Ammo -> Ammo
add name template ammo =
    Dict.update name
        (\value ->
            case value of
                Just items ->
                    Just (template :: items)

                Nothing ->
                    Just [ template ]
        )
        ammo


get : String -> Ammo -> Maybe Templates
get s ammo =
    Dict.get s ammo
