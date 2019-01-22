module World.Model exposing (Model(..), World)

import Array exposing (Array)
import Dict.Any as Dict
import Environment exposing (Environment)
import Http
import Layer exposing (Layer)
import Logic.GameFlow as Flow exposing (GameFlow(..), Model, update)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Task exposing (Task)
import WebGL
import World.Camera as Camera exposing (Camera)


type Model
    = Model World


type alias World =
    Flow.Model
        { layers : List (Layer ())
        , camera : Camera
        , delme : Array (Maybe Vec3)
        , positions : Array (Maybe Vec2)
        , dimensions : Array (Maybe Vec2)

        -- , animations : Dict.AnyDict String String String
        , animations2 : Array (Maybe Vec2)
        , velocities : Array (Maybe Vec2)
        }
