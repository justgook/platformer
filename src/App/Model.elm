module App.Model exposing (Model, init)

import App.Message as Message exposing (Message)
import Game.Main as Game
import Game.Model as Game
import Html
import Json.Decode as Json
import Task
import Window
import Random.Pcg as Random exposing (Seed)


type Input
    = Keyboard
    | GamePad
    | Touch


type alias Model =
    { device :
        { pixelRatio : Float
        , inputType : Input
        }
    , style : List (Html.Attribute Message)
    , game : Game.Model
    , seed : Seed
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
                |> Random.initialSeed

        input =
            flags
                |> Json.decodeValue (Json.field "input" Json.string)
                |> Result.withDefault ""
                |> (\i ->
                        case i of
                            "touch" ->
                                Touch

                            "gamepad" ->
                                GamePad

                            _ ->
                                Keyboard
                   )
    in
        defaultModel pixelRatio input seed ! [ requestWindowSize, Cmd.map Message.Game (Game.load levelUrl) ]


defaultModel : Float -> Input -> Seed -> Model
defaultModel pixelRatio input seed =
    { device =
        { pixelRatio = pixelRatio
        , inputType = input
        }
    , style = []
    , game = Game.init
    , seed = seed
    }


requestWindowSize : Cmd Message
requestWindowSize =
    Task.perform Message.Window Window.size
