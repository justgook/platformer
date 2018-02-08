module Game.Model exposing (Model, model)

import Game.Level as Level exposing (Level)


type alias Model =
    { author : String
    , pages : Int
    , level : Level
    }


model : Model
model =
    { author = ""
    , pages = 0
    , level = Level.model
    }
