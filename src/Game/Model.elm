module Game.Model exposing (Model, init)

import Game.TextureLoader as TextureLoader
import QuadTree exposing (QuadTree)
import Time exposing (Time)
import Util.Level as Level exposing (Level)


--exposing (Message, Model, init, load, update)


type alias Model =
    { level : Level
    , runtime : Time
    , widthRatio : Float
    , textures : TextureLoader.Model
    , collision : QuadTree (QuadTree.Bounded { data : { x : Float, y : Float, height : Float, width : Float } })
    }


init : Model
init =
    { level = Level.init
    , textures = TextureLoader.init
    , widthRatio = 1
    , runtime = 0
    , collision = QuadTree.emptyQuadTree (QuadTree.boundingBox 0 0 0 0) 0
    }
