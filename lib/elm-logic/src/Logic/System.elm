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
    , foldl2
    , foldl2Custom
    , foldl3
    , foldl4
    , map
    , start
    )

import Array
import Logic.Component as Component
import Logic.Internal exposing (indexedFoldlArray, indexedMap2, map2)


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


foldl2 :
    SetsReducer2 a b { a : Component.Set a, b : Component.Set b }
    -> Component.Spec a world
    -> Component.Spec b world
    -> System world
foldl2 f spec1 spec2 world =
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


applyIf : Bool -> (a -> a) -> a -> a
applyIf bool f world =
    if bool then
        f world

    else
        world


foldl2Custom :
    SetsReducer2 a b ( { a : Component.Set a, b : Component.Set b }, custom )
    -> Component.Spec a world
    -> Component.Spec b world
    -> System ( world, custom )
foldl2Custom f spec1 spec2 ( world, custom ) =
    let
        set1 i a ( acc, custom_ ) =
            ( { acc | a = Array.set i (Just a) acc.a }, custom_ )

        set2 i b ( acc, custom_ ) =
            ( { acc | b = Array.set i (Just b) acc.b }, custom_ )

        combined =
            { a = spec1.get world, b = spec2.get world }

        ( result, newCustom ) =
            indexedFoldlArray
                (\n value1 acc ->
                    let
                        value2 =
                            acc
                                |> Tuple.first
                                |> .b
                                |> Array.get n
                                |> Maybe.withDefault Nothing
                    in
                    Maybe.map2
                        (\a b ->
                            f ( a, set1 n ) ( b, set2 n ) acc
                        )
                        value1
                        value2
                        |> Maybe.withDefault acc
                )
                ( combined, custom )
                combined.a
    in
    ( world
        |> applyIf (result.a /= combined.a) (spec1.set result.a)
        |> applyIf (result.b /= combined.b) (spec2.set result.b)
    , newCustom
    )


type alias SetsReducer3 a b c acc =
    ( a, a -> acc -> acc )
    -> ( b, b -> acc -> acc )
    -> ( c, c -> acc -> acc )
    -> acc
    -> acc


foldl3 :
    SetsReducer3 a b c { a : Component.Set a, b : Component.Set b, c : Component.Set c }
    -> Component.Spec a world
    -> Component.Spec b world
    -> Component.Spec c world
    -> System world
foldl3 f spec1 spec2 spec3 world =
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
                    let
                        value2 =
                            Array.get n acc.b |> Maybe.withDefault Nothing

                        value3 =
                            Array.get n acc.c |> Maybe.withDefault Nothing
                    in
                    Maybe.map3 (\a b c -> f ( a, set1 n ) ( b, set2 n ) ( c, set3 n ) acc) value1 value2 value3
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


foldl4 :
    SetsReducer4 a b c d { a : Component.Set a, b : Component.Set b, c : Component.Set c, d : Component.Set d }
    -> Component.Spec a world
    -> Component.Spec b world
    -> Component.Spec c world
    -> Component.Spec d world
    -> System world
foldl4 f spec1 spec2 spec3 spec4 world =
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
            { a = spec1.get world, b = spec2.get world, c = spec3.get world, d = spec4.get world }

        result =
            indexedFoldlArray
                (\n value1 acc ->
                    Maybe.map4
                        (\a b c d ->
                            f ( a, set1 n ) ( b, set2 n ) ( c, set3 n ) ( d, set4 n ) acc
                        )
                        value1
                        (Array.get n acc.b |> Maybe.withDefault Nothing)
                        (Array.get n acc.c |> Maybe.withDefault Nothing)
                        (Array.get n acc.d |> Maybe.withDefault Nothing)
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
