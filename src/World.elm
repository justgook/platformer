module World exposing (World, init, update, view)

import Array exposing (Array)
import Dict.Any as Dict exposing (AnyDict)
import Environment exposing (Environment)
import Http
import Layer exposing (Layer)
import Logic.Entity as Entity
import Logic.GameFlow as Flow
import Logic.System as System
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (vec3)
import Task exposing (Task)
import Tiled.Level as Tiled
import WebGL
import World.Camera as Camera exposing (Camera)
import World.Component as Component
import World.Model exposing (Model(..))
import World.System as System


type alias World =
    World.Model.Model


update : Float -> World -> World
update delta (Model world) =
    let
        systems =
            System.animationsChanger

        newWorld =
            Flow.update systems delta world

        -- _ =
        --     newWorld |> .positions |> Debug.log "World::update"
    in
    Model newWorld


view : Environment -> World -> List WebGL.Entity
view env (Model m) =
    Layer.view env m.camera m.layers


init : Tiled.Level -> Task.Task Http.Error World
init level =
    Task.map
        (\layers ->
            let
                world =
                    { layers = layers
                    , camera = Camera.init level
                    , frame = 0
                    , runtime_ = 0
                    , flow = Flow.Running
                    , positions = Array.empty
                    , dimensions = Array.empty
                    , delme = Array.empty

                    -- , animations = Dict.empty (\_ -> "a")
                    , animations2 = Array.empty
                    , velocities = Array.empty
                    }
                        -- {- TEST STUFF -}
                        |> Entity.create 1
                        |> Entity.with ( Component.positions, vec2 11 11 )
                        |> Entity.with ( Component.dimensions, vec2 12 12 )
                        |> Tuple.second
                        |> Entity.create 2
                        |> Entity.with ( Component.positions, vec2 21 21 )
                        |> Entity.with ( Component.dimensions, vec2 22 22 )
                        |> Entity.with ( Component.velocities, vec2 23 23 )
                        |> Entity.with ( Component.animations, vec2 24 24 )
                        |> Entity.with ( Component.delme, vec3 25 25 25 )
                        |> Tuple.second
                        |> Entity.create 3
                        |> Entity.with ( Component.positions, vec2 31 31 )
                        |> Tuple.second

                _ =
                    world
                        |> System.foldl2
                            (\( a, seta ) ( b, setb ) acc ->
                                acc
                                    |> seta (vec2 0 0)
                            )
                            Component.positions
                            Component.dimensions

                -- |> Debug.log "World::init - System.step2"
                {- TEST STUFF -}
            in
            Model world
        )
        (Layer.init level)
