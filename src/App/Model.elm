module App.Model exposing (Model, init, model)

import App.Message as Message exposing (Message)
import Html
import Json.Decode as Json exposing (list, string)
import Task
import Time exposing (Time)
import Window exposing (Size)


type alias Model =
    { device :
        { pixelRatio : Float
        }
    , runtime : Float
    , style : List (Html.Attribute Message)
    , widthRatio : Float
    }


init : Json.Value -> ( Model, Cmd Message )
init flags =
    let
        pixelRatio =
            flags
                |> Json.decodeValue (Json.field "devicePixelRatio" Json.float)
                |> Result.withDefault 1
    in
    model ! [ requestWindowSize ]


model : Model
model =
    { device =
        { pixelRatio = 1
        }
    , runtime = 0
    , style = []
    , widthRatio = 1
    }


requestWindowSize : Cmd Message
requestWindowSize =
    Task.perform Message.Window Window.size
