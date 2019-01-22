module Logic.Internal exposing (indexedFoldlArray, indexedMap2, map2, map3, map4, map5)

import Array exposing (Array)


map2 : (a -> b -> result) -> Array a -> Array b -> Array result
map2 f ws =
    apply (Array.map f ws)


{-| -}
map3 : (a -> b -> c -> result) -> Array a -> Array b -> Array c -> Array result
map3 f ws xs =
    apply (map2 f ws xs)


{-| -}
map4 : (a -> b -> c -> d -> result) -> Array a -> Array b -> Array c -> Array d -> Array result
map4 f ws xs ys =
    apply (map3 f ws xs ys)


{-| -}
map5 : (a -> b -> c -> d -> e -> result) -> Array a -> Array b -> Array c -> Array d -> Array e -> Array result
map5 f ws xs ys zs =
    apply (map4 f ws xs ys zs)


indexedMap2 : (Int -> a -> b -> result) -> Array a -> Array b -> Array result
indexedMap2 f ws =
    apply (Array.indexedMap f ws)


indexedFoldlArray : (Int -> a -> b -> b) -> b -> Array a -> b
indexedFoldlArray func acc list =
    let
        step : a -> ( Int, b ) -> ( Int, b )
        step x ( i, thisAcc ) =
            ( i + 1, func i x thisAcc )
    in
    Tuple.second (Array.foldl step ( 0, acc ) list)


{-| Apply an array of functions to an array of values.
-}
apply : Array (a -> b) -> Array a -> Array b
apply fs xs =
    let
        l =
            min (Array.length fs) (Array.length xs)

        fs_ =
            Array.slice 0 l fs
    in
    fs_
        |> Array.indexedMap
            (\n f ->
                Maybe.map f (Array.get n xs)
            )
        |> Array.toList
        |> List.filterMap identity
        |> Array.fromList
