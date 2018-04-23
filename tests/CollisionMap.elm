module CollisionMap exposing (..)

import Array.Hamt as Array exposing (Array)
import Expect exposing (Expectation)
import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape as Collision
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Test exposing (..)


wrapCollsionData : Collision.Shape -> Collision.WithShape {}
wrapCollsionData shape =
    { shape = shape }


suite : Test
suite =
    describe "Game.Logic.Collision.Map"
        [ describe "Map.empty"
            [ test "creates same empty" <|
                \_ ->
                    let
                        _ =
                            Collision.empty ( 16, 16 )
                    in
                        Expect.pass
            , test "inserting" <|
                \_ ->
                    let
                        table =
                            Collision.empty ( 16, 16 )

                        items =
                            [ Collision.createAABB { p = vec2 8 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            , Collision.createAABB { p = vec2 24 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            , Collision.createAABB { p = vec2 40 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            , Collision.createAABB { p = vec2 56 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            ]
                                |> List.map wrapCollsionData
                    in
                        List.foldl (\item acc -> Collision.insert item acc) table items
                            |> Collision.table
                            |> Array.get 0
                            |> Maybe.withDefault Array.empty
                            |> Array.length
                            |> Expect.equal 4
            , test "intersection" <|
                \_ ->
                    let
                        table =
                            Collision.empty ( 16, 16 )

                        items =
                            [ Collision.createAABB { p = vec2 8 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            , Collision.createAABB { p = vec2 24 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            , Collision.createAABB { p = vec2 40 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            , Collision.createAABB { p = vec2 56 6.5, xw = vec2 8 0, yw = vec2 0 6.5 }
                            ]
                                |> List.map wrapCollsionData

                        shape =
                            Collision.createAABB { p = vec2 11 38, xw = vec2 22 0, yw = vec2 0 29 }
                                |> wrapCollsionData

                        collisionMap =
                            List.foldl (\item acc -> Collision.insert item acc) table items
                    in
                        Collision.intersection shape collisionMap
                            |> List.length
                            |> Expect.equal 3
            ]
        ]
