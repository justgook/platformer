module Physic exposing (Config, World, addBody, clear, empty, getConfig, getIndexed, setConfig, toList, update)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Broad.Grid
import Dict exposing (Dict)
import Physic.Narrow.Body as Body exposing (Body)


type alias World i =
    { static : Broad.Grid.Grid (Body i)
    , gravity : Vec2

    --    , enableSleeping : Bool
    , timScale : Float
    , indexed : Dict i (Body i)
    }


type alias Config =
    { gravity : Vec2

    --    , enableSleeping : Bool
    , timScale : Float
    , grid : Broad.Grid.NewConfig
    }


empty : World comparable
empty =
    { static = Broad.Grid.empty
    , gravity = vec2 0 -1

    --    , enableSleeping = False
    , timScale = 1
    , indexed = Dict.empty
    }


getConfig : World comparable -> Config
getConfig world =
    { gravity = world.gravity

    --    , enableSleeping = world.enableSleeping
    , timScale = world.timScale
    , grid = Broad.Grid.getConfig world.static
    }


setConfig : Config -> World comparable -> World comparable
setConfig config world =
    { world
        | static = Broad.Grid.setConfig config.grid world.static
        , gravity = config.gravity

        --        , enableSleeping = config.enableSleeping
        , timScale = config.timScale
    }


clear : World comparable -> World comparable
clear world =
    { world
        | static = Broad.Grid.optimize Body.union world.static
    }


addBody : Body comparable -> World comparable -> World comparable
addBody body ({ static, indexed } as engine) =
    let
        insert : Body i -> Broad.Grid.Grid (Body i) -> Broad.Grid.Grid (Body i)
        insert body_ grid =
            Broad.Grid.insert (Body.boundary body_) body_ grid
    in
    if Body.isStatic body then
        { engine | static = insert body static }

    else
        case Body.getIndex body of
            Just index ->
                { engine | indexed = Dict.insert index body indexed }

            Nothing ->
                engine


getIndexed : World comparable -> List ( comparable, Body comparable )
getIndexed { indexed } =
    indexed |> Dict.toList


toList : World comparable -> List (Body comparable)
toList world =
    Dict.values world.indexed ++ Broad.Grid.toList world.static


update dt ({ indexed, static } as world) =
    let
        --https://wildbunny.co.uk/blog/2011/03/25/speculative-contacts-an-continuous-collision-engine-approach-part-1/
        --http://buildnewgames.com/gamephysics/
        --https://codepen.io/schteppe/pen/YaEXab?editors=0010
        newIndexed =
            Dict.map
                (\_ body ->
                    let
                        boundary =
                            Body.boundary body

                        targets =
                            Broad.Grid.query boundary static
                                |> Dict.values

                        --                        _ =
                        --                            Debug.log "targets" targets
                    in
                    Body.translate (Body.getVelocity body) body
                )
                indexed
    in
    { world | indexed = newIndexed }
