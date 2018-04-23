module App.Model exposing (Model, init)

import App.Message as Message exposing (Message)
import Game.Main as Game
import Game.Model as Game
import Html
import Json.Decode as Json
import Task
import Window


type alias Model =
    { device :
        { pixelRatio : Float
        }
    , style : List (Html.Attribute Message)
    , game : Game.Model
    }


init : Json.Value -> ( Model, Cmd Message )
init flags =
    let
        pixelRatio =
            flags
                |> Json.decodeValue (Json.field "devicePixelRatio" Json.float)
                |> Result.withDefault 1

        levelUrl =
            flags
                |> Json.decodeValue (Json.field "levelUrl" Json.string)
                |> Result.withDefault "default.json"

        seed =
            flags
                |> Json.decodeValue (Json.field "seed" Json.int)
                |> Result.withDefault 227852860
    in
        defaultModel pixelRatio ! [ requestWindowSize, Cmd.map Message.Game (Game.load levelUrl) ]


defaultModel : Float -> Model
defaultModel pixelRatio =
    { device =
        { pixelRatio = pixelRatio
        }
    , style = []
    , game = Game.init
    }


requestWindowSize : Cmd Message
requestWindowSize =
    Task.perform Message.Window Window.size