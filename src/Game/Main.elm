module Game.Main exposing (load)

import Game.Message exposing (Message(..))
import Http
import Util.Level as Level


load : String -> Cmd Message
load url =
    Http.send LevelLoaded <| Http.get url Level.decode
