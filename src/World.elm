module World exposing (World(..), WorldTuple)

import Layer exposing (Layer)
import Logic.GameFlow as Flow
import World.Camera exposing (Camera)


type World world object
    = World
        (Flow.Model
            { layers : List (Layer object)
            , camera : Camera
            }
        )
        world


type alias WorldTuple world object =
    ( Flow.Model
        { layers : List (Layer object)
        , camera : Camera
        }
    , world
    )
