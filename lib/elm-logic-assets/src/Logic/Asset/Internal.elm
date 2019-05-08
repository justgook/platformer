module Logic.Asset.Internal exposing (Points(..), get, points, remap)

import AltMath.Vector2 exposing (Vec2)


remap : Float -> Float -> Float -> Float -> Float -> Float
remap start1 stop1 start2 stop2 n =
    let
        newVal =
            (n - start1) / (stop1 - start1) * (stop2 - start2) + start2
    in
    if start2 < stop2 then
        max start2 <| min newVal stop2

    else
        max stop2 <| min newVal start2


type Points
    = Points (Nonempty Vec2)


type Nonempty a
    = Nonempty a (List a)


points : Vec2 -> List Vec2 -> Points
points first rest =
    Points (Nonempty first rest)


get : Int -> Nonempty a -> a
get i ((Nonempty x xs) as ne) =
    let
        j =
            modBy (List.length xs + 1) i

        find k ys =
            case ys of
                [] ->
                    {- This should never happen, but to avoid Debug.crash,
                       we return the head of the list.
                    -}
                    x

                z :: zs ->
                    if k == 0 then
                        z

                    else
                        find (k - 1) zs
    in
    if j == 0 then
        x

    else
        find (j - 1) xs
