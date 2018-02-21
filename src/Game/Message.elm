module Game.Message exposing (Message(..))

import Game.TextureLoader as Texture
import Http
import Time exposing (Time)
import Util.Level exposing (Level)


type Message
    = LevelLoaded (Result Http.Error Level)
    | Texture Texture.Message
    | Animate Time
