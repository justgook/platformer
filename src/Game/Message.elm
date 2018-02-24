module Game.Message exposing (Message(..))

import Game.Logic.Message as Logic
import Game.Model as Game
import Game.TextureLoader as Texture
import Http
import Slime.Engine


type Message
    = LevelLoaded (Result Http.Error Game.Level)
    | Texture Texture.Message
    | Logic (Slime.Engine.Message Logic.Message)
