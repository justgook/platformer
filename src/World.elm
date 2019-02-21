module World exposing (World(..), WorldTuple)

import Layer exposing (Layer)
import Logic.GameFlow as Flow
import World.Camera exposing (Camera)


type World world
    = World
        (Flow.Model
            { layers : List Layer
            , camera : Camera
            }
        )
        world


type alias WorldTuple world =
    ( Flow.Model
        { layers : List Layer
        , camera : Camera
        }
    , world
    )
