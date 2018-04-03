module Game.Message exposing (Message(..))

import Game.Logic.Message as Logic
import Game.PostDecoder exposing (DecodedData)
import Game.TextureLoader as Texture
import Http
import Slime.Engine


type Message
    = LevelLoaded (Result Http.Error DecodedData)
    | Texture Texture.Message
    | Logic (Slime.Engine.Message Logic.Message)
