module Main exposing (main)

import Browser.Dom
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (style)
import Logic.Component as Component
import Logic.Entity as Entity
import Logic.GameFlow exposing (GameFlow(..))
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.System as System exposing (applyIf)
import Process
import Task


main : Launcher () World
main =
    Launcher.document game


game : Launcher.Document flags World
game =
    { init =
        \_ ->
            Process.sleep 0 |> Task.map (\_ -> spawn world)
    , subscriptions = \w -> Sub.none
    , update = \w -> ( system velocitySpec positionSpec w, Cmd.none )
    , view =
        \w ->
            System.foldl
                (\( px, py ) acc ->
                    div
                        [ style "width" "30px"
                        , style "height" "30px"
                        , style "position" "absolute"
                        , style "top" "0"
                        , style "left" "0"
                        , style "background" "red"
                        , style "transform" ("translate(" ++ String.fromInt px ++ "px, " ++ String.fromInt py ++ "px)")
                        ]
                        []
                        :: acc
                )
                (positionSpec.get w)
                []
    }


system =
    System.step2
        (\( ( vx, vy ), setVel ) ( ( px, py ), setPos ) acc ->
            let
                x =
                    vx + px

                y =
                    vy + py
            in
            acc
                |> setPos ( x, y )
                |> applyIf (x < 0) (setVel ( abs vx, vy ))
                |> applyIf (x > 300) (setVel ( abs vx * -1, vy ))
                |> applyIf (y < 0) (setVel ( vx, abs vy ))
                |> applyIf (y > 300) (setVel ( vx, abs vy * -1 ))
        )


type alias World =
    Launcher.World
        { position : Component.Set ( Int, Int )
        , velocity : Component.Set ( Int, Int )
        , windowWidth : Int
        , windowHeight : Int
        }


world : World
world =
    { frame = 0
    , runtime_ = 0
    , flow = Running
    , position = Component.empty
    , velocity = Component.empty
    , windowWidth = 0
    , windowHeight = 0
    }


spawn w_ =
    List.range 0 10
        |> List.foldl
            (\i w ->
                w
                    |> Entity.create i
                    |> Entity.with ( positionSpec, ( i * 3, i * 5 ) )
                    |> Entity.with ( velocitySpec, ( modBy 3 i + 1, modBy 5 i + 1 ) )
                    |> Tuple.second
            )
            w_
        |> Entity.create 11
        |> Entity.with ( positionSpec, ( 100, 100 ) )
        |> Entity.with ( velocitySpec, ( -1, -1 ) )
        |> Tuple.second
        |> Entity.create 12
        |> Entity.with ( positionSpec, ( 200, 200 ) )
        |> Entity.with ( velocitySpec, ( -1, -2 ) )
        |> Tuple.second


positionSpec : Component.Spec ( Int, Int ) { world | position : Component.Set ( Int, Int ) }
positionSpec =
    { get = .position
    , set = \comps w -> { w | position = comps }
    }


velocitySpec : Component.Spec ( Int, Int ) { world | velocity : Component.Set ( Int, Int ) }
velocitySpec =
    { get = .velocity
    , set = \comps w -> { w | velocity = comps }
    }
