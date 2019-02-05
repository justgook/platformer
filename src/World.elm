module World exposing (World, World2, init, update, view)

import Array exposing (Array)
import Dict.Any as Dict exposing (AnyDict)
import Ease exposing (Easing)
import Environment exposing (Environment)
import Http
import Layer exposing (Layer)
import List.Nonempty as NE exposing (Nonempty(..))
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


type alias World2 a =
    Flow.Model
        { a
            | layers : List Layer
            , camera : Camera
        }


update : Float -> World -> World
update delta (Model world) =
    let
        cameraPoints =
            Nonempty
                (vec3 0 0 160)
                [ vec3 0 0 200
                , vec3 5 0 250
                , vec3 7 0 300
                , vec3 0 0 350
                ]

        easing =
            Ease.bezier 0.645 0.045 0.355 1

        systems =
            System.animationsChanger
                >> System.demoCamera easing cameraPoints

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
