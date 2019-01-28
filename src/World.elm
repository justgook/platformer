module World exposing (World, init, update, view)

import Array exposing (Array)
import Dict.Any as Dict exposing (AnyDict)
import Environment exposing (Environment)
import Http
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
import World.Render
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
    in
    Model newWorld


view : Environment -> World -> List WebGL.Entity
view env world =
    World.Render.view env world


init : Tiled.Level -> Task.Task Http.Error World
init =
    World.Model.init
