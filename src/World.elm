module World exposing (World(..), WorldTuple)

import Environment exposing (Environment)
import Logic.GameFlow as Flow


type World world
    = World (Flow.Model { env : Environment }) world


type alias WorldTuple world =
    ( Flow.Model { env : Environment }, world )
