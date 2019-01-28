module System exposing (main)

import Array exposing (Array)
import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Logic.Entity as Entity exposing (EntityID, create, with)
import Logic.System exposing (andMap, end, endCustom, foldl2, foldl3, foldl4, map, start)


main : BenchmarkProgram
main =
    program suite


aspec =
    { get = .a
    , set = \comps w -> { w | a = comps }
    }


bspec =
    { get = .b
    , set = \comps w -> { w | b = comps }
    }


cspec =
    { get = .c
    , set = \comps w -> { w | c = comps }
    }


dspec =
    { get = .d
    , set = \comps w -> { w | d = comps }
    }


suite : Benchmark
suite =
    describe "System"
        [ -- nest as many descriptions as you like
          describe "folding2"
            [ benchmark "UnfinishedSystem" <|
                \_ -> unFinishedSystem2 world |> unFinishedSystem2
            , benchmark "FinishedSystem" <|
                \_ -> finishedSystem2 world |> finishedSystem2
            ]
        , describe "folding3"
            [ benchmark "UnfinishedSystem" <|
                \_ -> unFinishedSystem3 world |> unFinishedSystem3
            , benchmark "FinishedSystem" <|
                \_ -> finishedSystem3 world |> finishedSystem3
            ]
        , describe "folding4"
            [ benchmark "UnfinishedSystem" <|
                \_ -> unFinishedSystem4 world |> unFinishedSystem4
            , benchmark "FinishedSystem" <|
                \_ -> finishedSystem4 world |> finishedSystem4
            ]
        , describe "folding4 -> folding3 -> folding2"
            [ benchmark "UnfinishedSystem" <|
                \_ -> unFinishedSystem4 world |> unFinishedSystem3 |> unFinishedSystem2
            , benchmark "FinishedSystem" <|
                \_ -> finishedSystem4 world |> finishedSystem3 |> finishedSystem2
            ]
        ]


empty =
    { a = Array.empty
    , b = Array.empty
    , c = Array.empty
    , d = Array.empty
    }


world =
    List.range 0 100
        |> indexedFoldl
            (\i n acc ->
                acc
                    |> Entity.create i
                    |> Entity.with ( aspec, i )
                    |> Entity.with ( bspec, i )
                    |> Entity.with ( cspec, i )
                    |> Entity.with ( dspec, i )
                    |> Tuple.second
            )
            empty


system2 =
    \a b acc -> acc


finishedSystem2 =
    foldl2 system2 aspec bspec


unFinishedSystem2 =
    start system2 aspec
        >> andMap bspec
        >> end


system3 =
    \( a, _ ) ( b, _ ) ( c, setC ) acc -> setC (a + b + c) acc


finishedSystem3 =
    foldl3 system3 aspec bspec cspec


unFinishedSystem3 =
    start system3 aspec
        >> andMap bspec
        >> andMap cspec
        >> end


system4 =
    \a b c d acc -> acc


finishedSystem4 =
    foldl4 system4 aspec bspec cspec dspec


unFinishedSystem4 =
    start system4 aspec
        >> andMap bspec
        >> andMap cspec
        >> andMap dspec
        >> end


indexedFoldl : (Int -> a -> b -> b) -> b -> List a -> b
indexedFoldl func acc list =
    let
        step : a -> ( Int, b ) -> ( Int, b )
        step x ( i, thisAcc ) =
            ( i + 1, func i x thisAcc )
    in
    Tuple.second (List.foldl step ( 0, acc ) list)
