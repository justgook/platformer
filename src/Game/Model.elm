module Game.Model exposing (Level, Model, init)

import Game.Logic.World exposing (World, world)
import Game.TextureLoader as TextureLoader
import Util.Level exposing (Layer, LevelWith, Tileset)
import Util.Level.Special as Level exposing (LevelProps)


type alias Level =
    LevelWith LevelProps Layer Tileset


type alias Model =
    { level : LevelWith LevelProps Layer Tileset
    , widthRatio : Float
    , textures : TextureLoader.Model
    , world : World
    }


init : Model
init =
    { level = Level.init
    , textures = TextureLoader.init
    , widthRatio = 1
    , world = world
    }
