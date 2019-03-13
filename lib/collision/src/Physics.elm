module Physics exposing (Config, World, addBody, clear, empty, getConfig, setConfig, toList)

import Array exposing (Array)
import Broad.Grid
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Physic.Body exposing (Body)


type alias World =
    { static : Broad.Grid.Grid Body
    , gravity : Vec2
    , enableSleeping : Bool
    , timScale : Float
    , dynamic : Array (Maybe Body) -- Should i change it to some other type of Grid?
    }


type alias Config =
    { gravity : Vec2
    , enableSleeping : Bool
    , timScale : Float
    , grid : Broad.Grid.NewConfig
    }


empty : World
empty =
    { static = Broad.Grid.empty
    , gravity = vec2 0 -1
    , enableSleeping = False
    , timScale = 1
    , dynamic = Array.empty
    }


getConfig : World -> Config
getConfig world =
    { gravity = world.gravity
    , enableSleeping = world.enableSleeping
    , timScale = world.timScale
    , grid = Broad.Grid.getConfig world.static
    }


setConfig : Config -> World -> World
setConfig config world =
    { world
        | static = Broad.Grid.setConfig config.grid world.static
        , gravity = config.gravity
        , enableSleeping = config.enableSleeping
        , timScale = config.timScale
    }


clear : World -> World
clear world =
    { world
        | static =
            world.static
                |> Broad.Grid.optimize Physic.Body.union
    }


addBody : Body -> World -> World
addBody body ({ static } as engine) =
    let
        insert : Body -> Broad.Grid.Grid Body -> Broad.Grid.Grid Body
        insert body_ grid =
            Broad.Grid.insert (Physic.Body.boundary body_) body_ grid
    in
    if Physic.Body.isStatic body then
        { engine | static = insert body static }

    else
        engine


toList : World -> List Body
toList world =
    Broad.Grid.toList world.static


update delta world =
    world
