module App.Model exposing (Model, init, model)

import App.Message as Message exposing (Message)
import Game.Main as Game
import Game.Model as Game
import Html
import Json.Decode as Json exposing (list, string)
import Task
import Time exposing (Time)
import Window exposing (Size)


type alias Model =
    { device :
        { pixelRatio : Float
        }
    , runtime : Time
    , style : List (Html.Attribute Message)
    , widthRatio : Float
    , game : Game.Model
    }


init : Json.Value -> ( Model, Cmd Message )
init flags =
    let
        pixelRatio =
            flags
                |> Json.decodeValue (Json.field "devicePixelRatio" Json.float)
                |> Result.withDefault 1
    in
    model ! [ requestWindowSize, Cmd.map Message.Game (Game.load "http://localhost:8080/WIP/level1/level.json") ]


model : Model
model =
    { device =
        { pixelRatio = 1
        }
    , runtime = 0
    , style = []
    , widthRatio = 1
    , game = Game.model
    }


requestWindowSize : Cmd Message
requestWindowSize =
    Task.perform Message.Window Window.size
