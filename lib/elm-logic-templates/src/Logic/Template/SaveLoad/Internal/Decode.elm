module Logic.Template.SaveLoad.Internal.Decode exposing
    ( andMap
    , bool
    , components
    , float
    , foldl
    , id
    , reverseList
    , sequence
    , sizedString
    , xy
    , xyz
    , xyzw
    )

import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder, Step(..), andThen, loop, map, succeed, unsignedInt32)
import Logic.Component as Component
import Logic.Entity as Entity


sequence : List (Decoder (a -> a)) -> Decoder (a -> a)
sequence =
    List.foldl (D.map2 (<<)) (D.succeed identity)



--
--decodeWithTexture : List (Decoder (b -> a -> a)) -> Bytes -> Maybe (b -> a -> a)
--decodeWithTexture decoders =
--    D.decode (sequence2 (List.reverse decoders))


sequence2 : List (Decoder (b -> a -> a)) -> Decoder (b -> a -> a)
sequence2 =
    List.foldl (D.map2 composeBAA) (D.succeed (\_ a -> a))


composeBAA : (b -> a -> a) -> (b -> a -> a) -> b -> a -> a
composeBAA f g b a =
    f b (g b a)



--andMap : Decoder a -> Decoder (a -> b) -> Decoder b
--andMap =
--    D.map2 (|>)
--


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap argument function =
    D.map2 (<|) function argument


float : Decoder Float
float =
    D.float32 BE


bool : Decoder Bool
bool =
    D.unsignedInt8
        |> D.map
            (\a ->
                if a == 1 then
                    True

                else
                    False
            )


xy : Decoder { x : Float, y : Float }
xy =
    D.map2 (\x y -> { x = x, y = y })
        float
        float


xyz : Decoder { x : Float, y : Float, z : Float }
xyz =
    D.map3 (\x y z -> { x = x, y = y, z = z })
        float
        float
        float


xyzw : Decoder { x : Float, y : Float, z : Float, w : Float }
xyzw =
    D.map4 (\x y z w -> { x = x, y = y, z = z, w = w })
        float
        float
        float
        float


id : Decoder Int
id =
    D.unsignedInt32 BE


sizedString : Decoder String
sizedString =
    D.unsignedInt32 BE
        |> D.andThen D.string


reverseList : Decoder a -> Decoder (List a)
reverseList decoder =
    unsignedInt32 BE
        |> andThen (\len -> loop ( len, [] ) (listStep decoder))


listStep : Decoder a -> ( Int, List a ) -> Decoder (Step ( Int, List a ) (List a))
listStep decoder ( n, xs ) =
    if n <= 0 then
        succeed (Done xs)

    else
        map (\x -> Loop ( n - 1, x :: xs )) decoder


foldl : Int -> (b -> Decoder b) -> b -> Decoder b
foldl count decoder acc =
    D.loop ( count, acc ) (foldlStep decoder)


foldlStep : (a -> Decoder b) -> ( Int, a ) -> Decoder (Step ( Int, b ) a)
foldlStep decoder ( n, acc ) =
    if n <= 0 then
        D.succeed (Done acc)

    else
        D.map (\x -> Loop ( n - 1, x )) (decoder acc)


components : Decoder a -> Decoder (Component.Set a)
components d =
    reverseList (D.map2 (\id_ shapes -> ( id_, shapes )) id d)
        |> D.map Entity.fromList
