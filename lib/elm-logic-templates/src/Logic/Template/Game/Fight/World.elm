module Logic.Template.Game.Fight.World exposing (FightWorld, empty)

import Dict exposing (Dict)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity exposing (EntityID)
import Logic.GameFlow as Flow
import Logic.Launcher as Launcher
import Logic.Template.Component.IdSource as IdSource exposing (IdSource)
import Logic.Template.Component.Network.Status as Status exposing (Status)
import Logic.Template.Component.Position as Position exposing (Position)
import Logic.Template.Component.Velocity as Velocity exposing (Velocity)
import Logic.Template.Input as Input exposing (Input, InputSingleton)
import Logic.Template.Network exposing (SessionId)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Random


type alias FightWorld =
    Launcher.World
        { render : RenderInfo
        , input : InputSingleton
        , position : Component.Set Position
        , velocity : Component.Set Velocity
        , idSource : IdSource
        , seed : Random.Seed

        --Network
        , status : Status
        , online : Dict SessionId EntityID
        }


empty : FightWorld
empty =
    { frame = 0
    , runtime_ = 0
    , flow = Flow.Running
    , render = RenderInfo.empty
    , input = Input.empty --{ inputEmpty | registered = testKeys 0 }
    , position = Position.empty
    , velocity = Velocity.empty
    , idSource = IdSource.empty 1
    , seed = Random.initialSeed 42

    --Network
    , status = Status.empty
    , online = Dict.empty
    }
