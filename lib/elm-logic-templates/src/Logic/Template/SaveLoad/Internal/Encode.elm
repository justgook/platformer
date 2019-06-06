module Logic.Template.SaveLoad.Internal.Encode exposing (bool, encoder, float, id, list, sizedString, xy, xyz)

import Bytes exposing (Endianness(..))
import Bytes.Encode as E exposing (Encoder)


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


xyz : { x : Float, y : Float, z : Float } -> Encoder
xyz { x, y, z } =
    E.sequence
        [ float x
        , float y
        , float z
        ]


id : Int -> Encoder
id =
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
