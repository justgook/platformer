module Environment exposing (Environment, Message, init, style, subscriptions, update)

import Browser.Dom as Browser
import Browser.Events as Events
import Json.Decode as Decode
import Task
import VirtualDom


type alias Environment =
    { height : Int
    , width : Int
    , devicePixelRatio : Float
    , widthRatio : Float
    }


type Message
    = Resize Int Int


subscriptions : Environment -> Sub Message
subscriptions model =
    Sub.batch
        [ Events.onResize Resize
        ]


update : Message -> Environment -> Environment
update msg model =
    case msg of
        Resize w h ->
            { model
                | width = w
                , height = h
                , widthRatio = toFloat w / toFloat h
            }


init : Decode.Value -> ( Environment, Cmd Message )
init flags =
    ( { height = 100
      , width = 100
      , widthRatio = 1
      , devicePixelRatio =
            flags
                |> Decode.decodeValue (Decode.field "devicePixelRatio" Decode.float)
                |> Result.withDefault 1
      }
    , requestWindowSize
    )


requestWindowSize : Cmd Message
requestWindowSize =
    Browser.getViewport
        |> Task.perform (\{ scene } -> Resize (round scene.width) (round scene.height))


style : Environment -> List (VirtualDom.Attribute msg)
style env =
    [ toFloat env.width * env.devicePixelRatio |> round |> String.fromInt |> VirtualDom.attribute "width"
    , toFloat env.height * env.devicePixelRatio |> round |> String.fromInt |> VirtualDom.attribute "height"
    , VirtualDom.style "display" "block"
    , VirtualDom.style "width" (String.fromInt env.width ++ "px")
    , VirtualDom.style "height" (String.fromInt env.height ++ "px")
    ]



-- parseKey : Bool -> { a | y : Int, x : Int } -> Decoder Message
-- parseKey pressed controls =
--     Decode.field "keyCode" Decode.int
--         |> Decode.andThen
--             (dirFromKeyCode
--                 >> parseControls pressed controls
--                 >> Maybe.map (Logic.Control >> Slime.Engine.Msg >> Develop.Logic >> Message.Develop >> Decode.succeed)
--                 >> Maybe.withDefault (Decode.fail "No needed update")
--             )
