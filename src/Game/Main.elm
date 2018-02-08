module Game.Main exposing (load)

import Game.Level exposing (decodeLevel)
import Game.Message exposing (Message(..))
import Game.Model exposing (Model)
import Http
import Json.Decode as Decode


load : String -> Cmd Message
load url =
    Http.send LoadLevel <| Http.get url decodeLevel
