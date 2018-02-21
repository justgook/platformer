module Game.ECS.Update exposing (update)

import Game.ECS.Engine exposing (engine)
import Slime.Engine


update msg model =
    let
        ( updatedWorld, cmds ) =
            Slime.Engine.engineUpdate engine msg model.world
    in
    ( { model
        | world = updatedWorld
      }
    , cmds
    )
