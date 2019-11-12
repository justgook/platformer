module Logic.Template.SaveLoad.Internal.Encode exposing (bool, components, encodedList, encoder, float, id, int, list, maybe, sizedString, vec2, xy, xyz, xyzw)

import AltMath.Vector2 as AltVec2
import Bytes exposing (Endianness(..))
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component
import Logic.Entity as Entity


encoder encoders w =
    List.map (\f -> f w) encoders
        |> E.sequence


float : Float -> Encoder
float =
    E.float32 BE


bool : Bool -> Encoder
bool a =
    if a then
        E.unsignedInt8 1

    else
        E.unsignedInt8 0


xy : { x : Float, y : Float } -> Encoder
xy { x, y } =
    E.sequence [ float x, float y ]


vec2 : AltVec2.Vec2 -> Encoder
vec2 v =
    let
        { x, y } =
            AltVec2.toRecord v
    in
    E.sequence [ float x, float y ]


xyz : { x : Float, y : Float, z : Float } -> Encoder
xyz { x, y, z } =
    E.sequence
        [ float x
        , float y
        , float z
        ]


xyzw : { x : Float, y : Float, z : Float, w : Float } -> Encoder
xyzw { x, y, z, w } =
    E.sequence
        [ float x
        , float y
        , float z
        , float w
        ]


id : Int -> Encoder
id =
    E.unsignedInt32 BE


int : Int -> Encoder
int =
    E.unsignedInt32 BE


sizedString : String -> Encoder
sizedString str =
    E.sequence
        [ E.unsignedInt32 BE (E.getStringWidth str)
        , E.string str
        ]


list : (a -> Encoder) -> List a -> Encoder
list f l =
    E.sequence (E.unsignedInt32 BE (List.length l) :: List.map f l)


encodedList : List Encoder -> Encoder
encodedList l =
    E.sequence (id (List.length l) :: l)


maybe : (a -> Encoder) -> Maybe a -> Encoder
maybe f m =
    case m of
        Just info ->
            E.sequence [ E.unsignedInt8 1, f info ]

        Nothing ->
            E.unsignedInt8 0


components : (b -> Encoder) -> Component.Set b -> Encoder
components e =
    Entity.toList
        >> list
            (\( id_, shapes ) ->
                E.sequence [ id id_, e shapes ]
            )
