module Generate.Util exposing (rangeList)

import Fuzz exposing (Fuzzer, intRange)
import Random exposing (Generator)


rangeList : Int -> Int -> Fuzzer a -> Fuzzer (List a)
rangeList lo hi fuzzer =
    Fuzz.intRange lo hi
        |> Fuzz.map (\i -> List.repeat i "12")
        |> Fuzz.map2 (\f l -> List.map (always f) l) fuzzer
