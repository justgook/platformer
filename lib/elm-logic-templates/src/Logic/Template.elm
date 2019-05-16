module Logic.Template exposing (platformer)

import Logic.Launcher exposing (Error, Launcher, World)
import Task exposing (Task)
import VirtualDom


platformer :
    { init : flag -> Task Error (World world)
    , subscriptions : World world -> Sub (World world)
    , update : World world -> World world
    , view :
        World world
        -> List (VirtualDom.Node (World world -> World world))
    }
platformer =
    "platformer"
