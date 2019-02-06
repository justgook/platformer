module World exposing (World(..))

import Layer exposing (Layer)
import Logic.GameFlow as Flow
import World.Camera as Camera exposing (Camera)


type World world object
    = World
        (Flow.Model
            { layers : List (Layer object)
            , camera : Camera
            }
        )
        world
