module World exposing (World(..), WorldTuple)

import Environment exposing (Environment)
import Layer exposing (Layer)
import Logic.GameFlow as Flow


type World world
    = World
        (Flow.Model
            { layers : List Layer
            , env : Environment
            }
        )
        world


type alias WorldTuple world =
    ( Flow.Model { layers : List Layer, env : Environment }, world )
