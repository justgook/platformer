module Logic.System exposing (Setter, System, UnfinishedSystem, andMap, end, foldl2, foldl3, foldl4, map, start)

import Array exposing (Array)
import Logic.Component as Component
import Logic.Internal exposing (indexedFoldlArray, indexedMap2, map2)


type alias System world =
    world -> world


type UnfinishedSystem world acc next func
    = UnfinishedSystem
        { acc : next -> acc
        , apply : world -> acc -> world
        , arrayFunction : Array.Array (Maybe func)
        , itemsFromAcc :
            { get : acc -> next
            , map : (next -> next) -> acc -> acc
            }
        , world : world
        }


start :
    (( comp, acc -> ( Array.Array (Maybe acc), next ) -> ( Array.Array (Maybe acc), next ) ) -> func)
    -> Component.Spec comp world
    -> world
    -> UnfinishedSystem world ( Component.Set comp, next ) next func
start f spec world =
    let
        componentSet =
            spec.get world

        itemsGetter =
            Tuple.first

        itemsMapper =
            Tuple.mapFirst

        valueSetter2 i value acc_ =
            itemsMapper (Array.set i (Just value)) acc_
    in
    UnfinishedSystem
        { world = world
        , acc = \n -> ( componentSet, n )
        , itemsFromAcc =
            { get = Tuple.second
            , map = Tuple.mapSecond
            }
        , apply = \w acc -> spec.set (itemsGetter acc) w
        , arrayFunction =
            Array.indexedMap (\i -> Maybe.map (\v -> f ( v, valueSetter2 i ))) componentSet
        }


andMap :
    Component.Spec comp world
    -> UnfinishedSystem world acc ( Component.Set comp, next ) (( comp, comp -> acc -> acc ) -> newFunc)
    -> UnfinishedSystem world acc next newFunc
andMap spec (UnfinishedSystem { world, acc, apply, arrayFunction, itemsFromAcc }) =
    let
        componentSet =
            spec.get world

        newAcc f a b =
            f ( a, b )

        itemsGetter =
            itemsFromAcc.get >> Tuple.first

        itemsMapper =
            Tuple.mapFirst >> itemsFromAcc.map

        valueSetter2 i value acc_ =
            itemsMapper (Array.set i (Just value)) acc_

        newApply w acc_ =
            apply w acc_ |> spec.set (itemsGetter acc_)

        newFuncArray =
            indexedMap2
                (\i value function ->
                    Maybe.map2 (\a b -> a ( b, valueSetter2 i )) function value
                )
                componentSet
                arrayFunction
    in
    UnfinishedSystem
        { world = world
        , acc = newAcc acc componentSet
        , apply = newApply
        , arrayFunction = newFuncArray
        , itemsFromAcc =
            { get = itemsFromAcc.get >> Tuple.second
            , map = Tuple.mapSecond >> itemsFromAcc.map
            }
        }


end : UnfinishedSystem world acc () (acc -> acc) -> world
end (UnfinishedSystem { world, acc, arrayFunction, apply }) =
    Array.foldl
        (\f acc_ ->
            Maybe.map (\f_ -> f_ acc_) f
                |> Maybe.withDefault acc_
        )
        (acc ())
        arrayFunction
        |> apply world


map f { get, set } world =
    set (get world |> Array.map (Maybe.map f)) world


type alias Setter a acc =
    a -> acc -> acc


type alias Callback2 a b =
    ( a, Setter a (Accumulator2 a b) )
    -> ( b, Setter b (Accumulator2 a b) )
    -> Accumulator2 a b
    -> Accumulator2 a b


type alias Accumulator2 a b =
    { a : Component.Set a, b : Component.Set b }


foldl2 :
    Callback2 a b
    -> Component.Spec a world
    -> Component.Spec b world
    -> world
    -> world
foldl2 f spec1 spec2 world =
    let
        comp1arr =
            spec1.get world

        comp2arr =
            spec2.get world

        set1 i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        set2 i b acc =
            { acc | b = Array.set i (Just b) acc.b }

        combined =
            { a = comp1arr, b = comp2arr }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    let
                        value2 =
                            Array.get n acc.b |> Maybe.withDefault Nothing
                    in
                    Maybe.map2
                        (\a b ->
                            f ( a, set1 n ) ( b, set2 n ) acc
                        )
                        value1
                        value2
                        |> Maybe.withDefault acc
                )
                combined
                combined.a
    in
    world |> spec1.set result.a |> spec2.set result.b


type alias Accumulator3 a b c =
    { a : Component.Set a
    , b : Component.Set b
    , c : Component.Set c
    }


type alias Callback3 a b c =
    ( a, Setter a (Accumulator3 a b c) )
    -> ( b, Setter b (Accumulator3 a b c) )
    -> ( c, Setter c (Accumulator3 a b c) )
    -> Accumulator3 a b c
    -> Accumulator3 a b c


foldl3 :
    Callback3 a b c
    -> Component.Spec a world
    -> Component.Spec b world
    -> Component.Spec c world
    -> world
    -> world
foldl3 f spec1 spec2 spec3 world =
    let
        comp1arr =
            spec1.get world

        comp2arr =
            spec2.get world

        comp3arr =
            spec3.get world

        set1 i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        set2 i b acc =
            { acc | b = Array.set i (Just b) acc.b }

        set3 i c acc =
            { acc | c = Array.set i (Just c) acc.c }

        combined =
            { a = comp1arr, b = comp2arr, c = comp3arr }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    let
                        value2 =
                            Array.get n acc.b |> Maybe.withDefault Nothing

                        value3 =
                            Array.get n acc.c |> Maybe.withDefault Nothing
                    in
                    Maybe.map3
                        (\a b c ->
                            f ( a, set1 n ) ( b, set2 n ) ( c, set3 n ) acc
                        )
                        value1
                        value2
                        value3
                        |> Maybe.withDefault acc
                )
                combined
                combined.a
    in
    world
        |> spec1.set result.a
        |> spec2.set result.b
        |> spec3.set result.c


type alias Accumulator4 a b c d =
    { a : Component.Set a
    , b : Component.Set b
    , c : Component.Set c
    , d : Component.Set d
    }


type alias Callback4 a b c d =
    ( a, Setter a (Accumulator4 a b c d) )
    -> ( b, Setter b (Accumulator4 a b c d) )
    -> ( c, Setter c (Accumulator4 a b c d) )
    -> ( d, Setter d (Accumulator4 a b c d) )
    -> Accumulator4 a b c d
    -> Accumulator4 a b c d


foldl4 :
    Callback4 a b c d
    -> Component.Spec a world
    -> Component.Spec b world
    -> Component.Spec c world
    -> Component.Spec d world
    -> world
    -> world
foldl4 f spec1 spec2 spec3 spec4 world =
    let
        comp1arr =
            spec1.get world

        comp2arr =
            spec2.get world

        comp3arr =
            spec3.get world

        comp4arr =
            spec4.get world

        set1 i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        set2 i b acc =
            { acc | b = Array.set i (Just b) acc.b }

        set3 i c acc =
            { acc | c = Array.set i (Just c) acc.c }

        set4 i d acc =
            { acc | d = Array.set i (Just d) acc.d }

        combined =
            { a = comp1arr, b = comp2arr, c = comp3arr, d = comp4arr }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    let
                        value2 =
                            Array.get n acc.b |> Maybe.withDefault Nothing

                        value3 =
                            Array.get n acc.c |> Maybe.withDefault Nothing

                        value4 =
                            Array.get n acc.d |> Maybe.withDefault Nothing
                    in
                    Maybe.map4
                        (\a b c d ->
                            f ( a, set1 n ) ( b, set2 n ) ( c, set3 n ) ( d, set4 n ) acc
                        )
                        value1
                        value2
                        value3
                        value4
                        |> Maybe.withDefault acc
                )
                combined
                combined.a
    in
    world
        |> spec1.set result.a
        |> spec2.set result.b
        |> spec3.set result.c
        |> spec4.set result.d
