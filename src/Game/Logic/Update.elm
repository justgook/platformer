module Game.Logic.Update exposing (update)

import Game.Logic.Engine exposing (engine)
import Game.Logic.Message exposing (Message)
import Game.Logic.World exposing (World)
import Slime.Engine


update : Slime.Engine.Message Message -> World -> ( World, Cmd (Slime.Engine.Message Message) )
update =
    Slime.Engine.engineUpdate engine
