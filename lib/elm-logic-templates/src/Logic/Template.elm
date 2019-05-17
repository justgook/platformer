module Logic.Template exposing (jumper)

import Logic.Launcher exposing (Error, Launcher, World)
import Task exposing (Task)
import VirtualDom


jumper :
    { init : flag -> Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> World world
    , view :
        World world
        -> List (VirtualDom.Node (World world -> World world))
    }
jumper =
    "platformer"
