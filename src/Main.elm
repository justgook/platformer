module Main exposing (main)

import Game exposing (document)
import World exposing (World2)
import World.Component as Component
import World.System as System


main =
    document


systems =
    System.animationsChanger


type alias Model =
    World2 { positions : Component.Positions }
