module Logic.System exposing
    ( SetsReducer2
    , SetsReducer3
    , SetsReducer4
    , System
    , TupleSystem
    , UnfinishedSystem
    , andMap
    , end
    , endCustom
    , foldl
    , foldl2
    , foldl3
    , foldl4
    , map
    , start
    , step2
    , step3
    , step4
    )

import Array
import Logic.Component as Component
import Logic.Internal exposing (indexedFoldlArray, indexedMap2)


type alias System world =
    world -> world


type alias TupleSystem world acc =
    ( world, acc ) -> ( world, acc )


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


foldl : (comp1 -> acc -> acc) -> Component.Set comp1 -> acc -> acc
foldl f comp1 acc_ =
    indexedFoldlArray
        (\n value1 acc ->
            value1
                |> Maybe.map (\a -> f a acc)
                |> Maybe.withDefault acc
        )
        acc_
        comp1


foldl2 : (comp1 -> comp2 -> acc -> acc) -> Component.Set comp1 -> Component.Set comp2 -> acc -> acc
foldl2 f comp1 comp2 acc_ =
    indexedFoldlArray
        (\n value1 acc ->
            value1
                |> Maybe.andThen
                    (\a ->
                        Array.get n comp2
                            |> (Maybe.map >> Maybe.andThen)
                                (\b ->
                                    f a b acc
                                )
                    )
                |> Maybe.withDefault acc
        )
        acc_
        comp1


foldl3 : (comp1 -> comp2 -> comp3 -> acc -> acc) -> Component.Set comp1 -> Component.Set comp2 -> Component.Set comp3 -> acc -> acc
foldl3 f comp1 comp2 comp3 acc_ =
    indexedFoldlArray
        (\n value1 acc ->
            value1
                |> Maybe.andThen
                    (\a ->
                        (Maybe.andThen >> Maybe.andThen)
                            (\b ->
                                (Maybe.map >> Maybe.andThen)
                                    (\c ->
                                        f a b c acc
                                    )
                                    (Array.get n comp3)
                            )
                            (Array.get n comp2)
                    )
                |> Maybe.withDefault acc
        )
        acc_
        comp1


foldl4 :
    (comp1 -> comp2 -> comp3 -> comp4 -> acc -> acc)
    -> Component.Set comp1
    -> Component.Set comp2
    -> Component.Set comp3
    -> Component.Set comp4
    -> acc
    -> acc
foldl4 f comp1 comp2 comp3 comp4 acc_ =
    indexedFoldlArray
        (\n value1 acc ->
            Maybe.andThen
                (\a ->
                    (Maybe.andThen >> Maybe.andThen)
                        (\b ->
                            (Maybe.andThen >> Maybe.andThen)
                                (\c ->
                                    (Maybe.map >> Maybe.andThen)
                                        (\d ->
                                            f a b c d acc
                                        )
                                        (Array.get n comp4)
                                )
                                (Array.get n comp3)
                        )
                        (Array.get n comp2)
                )
                value1
                |> Maybe.withDefault acc
        )
        acc_
        comp1


{-| 3 times slower then `foldN`
-}
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


endCustom : custom -> UnfinishedSystem world acc () (( acc, custom ) -> ( acc, custom )) -> ( world, custom )
endCustom custom (UnfinishedSystem { world, acc, arrayFunction, apply }) =
    Array.foldl
        (\f acc_ ->
            Maybe.map (\f_ -> f_ acc_) f
                |> Maybe.withDefault acc_
        )
        ( acc (), custom )
        arrayFunction
        |> Tuple.mapFirst (apply world)


map : (comp -> comp) -> Component.Spec comp world -> System world
map f { get, set } world =
    set (get world |> Array.map (Maybe.map f)) world


type alias SetsReducer2 a b acc =
    ( a, a -> acc -> acc )
    -> ( b, b -> acc -> acc )
    -> acc
    -> acc


step2 :
    SetsReducer2 a b { a : Component.Set a, b : Component.Set b }
    -> Component.Spec a world
    -> Component.Spec b world
    -> System world
step2 f spec1 spec2 world =
    let
        set1 i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        set2 i b acc =
            { acc | b = Array.set i (Just b) acc.b }

        combined =
            { a = spec1.get world, b = spec2.get world }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    value1
                        |> Maybe.andThen
                            (\a ->
                                Array.get n acc.b
                                    |> (Maybe.map >> Maybe.andThen)
                                        (\b ->
                                            f ( a, set1 n ) ( b, set2 n ) acc
                                        )
                            )
                        |> Maybe.withDefault acc
                )
                combined
                combined.a
    in
    world
        |> applyIf (result.a /= combined.a) (spec1.set result.a)
        |> applyIf (result.b /= combined.b) (spec2.set result.b)


applyIf : Bool -> (a -> a) -> a -> a
applyIf bool f world =
    if bool then
        f world

    else
        world


type alias SetsReducer3 a b c acc =
    ( a, a -> acc -> acc )
    -> ( b, b -> acc -> acc )
    -> ( c, c -> acc -> acc )
    -> acc
    -> acc


step3 :
    SetsReducer3 a b c { a : Component.Set a, b : Component.Set b, c : Component.Set c }
    -> Component.Spec a world
    -> Component.Spec b world
    -> Component.Spec c world
    -> System world
step3 f spec1 spec2 spec3 world =
    let
        set1 i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        set2 i b acc =
            { acc | b = Array.set i (Just b) acc.b }

        set3 i c acc =
            { acc | c = Array.set i (Just c) acc.c }

        combined =
            { a = spec1.get world, b = spec2.get world, c = spec3.get world }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    value1
                        |> Maybe.andThen
                            (\a ->
                                (Maybe.andThen >> Maybe.andThen)
                                    (\b ->
                                        (Maybe.map >> Maybe.andThen)
                                            (\c ->
                                                f ( a, set1 n ) ( b, set2 n ) ( c, set3 n ) acc
                                            )
                                            (Array.get n acc.c)
                                    )
                                    (Array.get n acc.b)
                            )
                        |> Maybe.withDefault acc
                )
                combined
                combined.a
    in
    world
        |> applyIf (result.a /= combined.a) (spec1.set result.a)
        |> applyIf (result.b /= combined.b) (spec2.set result.b)
        |> applyIf (result.c /= combined.c) (spec3.set result.c)


type alias SetsReducer4 a b c d acc =
    ( a, a -> acc -> acc )
    -> ( b, b -> acc -> acc )
    -> ( c, c -> acc -> acc )
    -> ( d, d -> acc -> acc )
    -> acc
    -> acc


step4 :
    SetsReducer4 a b c d { a : Component.Set a, b : Component.Set b, c : Component.Set c, d : Component.Set d }
    -> Component.Spec a world
    -> Component.Spec b world
    -> Component.Spec c world
    -> Component.Spec d world
    -> System world
step4 f spec1 spec2 spec3 spec4 world =
    let
        set1 i a acc =
            { acc | a = Array.set i (Just a) acc.a }

        set2 i b acc =
            { acc | b = Array.set i (Just b) acc.b }

        set3 i c acc =
            { acc | c = Array.set i (Just c) acc.c }

        set4 i d acc =
            { acc | d = Array.set i (Just d) acc.d }

        combined =
            { a = spec1.get world
            , b = spec2.get world
            , c = spec3.get world
            , d = spec4.get world
            }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    Maybe.andThen
                        (\a ->
                            (Maybe.andThen >> Maybe.andThen)
                                (\b ->
                                    (Maybe.andThen >> Maybe.andThen)
                                        (\c ->
                                            (Maybe.map >> Maybe.andThen)
                                                (\d ->
                                                    f ( a, set1 n ) ( b, set2 n ) ( c, set3 n ) ( d, set4 n ) acc
                                                )
                                                (Array.get n acc.d)
                                        )
                                        (Array.get n acc.c)
                                )
                                (Array.get n acc.b)
                        )
                        value1
                        |> Maybe.withDefault acc
                )
                combined
                combined.a
    in
    world
        |> applyIf (result.a /= combined.a) (spec1.set result.a)
        |> applyIf (result.b /= combined.b) (spec2.set result.b)
        |> applyIf (result.c /= combined.c) (spec3.set result.c)
        |> applyIf (result.d /= combined.d) (spec4.set result.d)
