port module Fight.Game exposing (..)

import Base64
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Encode as Eb
import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (DocumentWith, Launcher)
import Logic.Template.Game.Fight as Game


port income : (String -> msg) -> Sub msg


port outcome : String -> Cmd msg


outcome_ : Bytes -> Cmd msg
outcome_ info =
    Base64.fromBytes info
        |> Maybe.map outcome
        |> Maybe.withDefault Cmd.none


income_ : (Bytes -> msg) -> Sub msg
income_ fn =
    income
        (Base64.toBytes
            >> Maybe.withDefault (Eb.encode (Eb.unsignedInt8 0))
            >> fn
        )


game : DocumentWith Value Game.World
game =
    Game.game income_ outcome_


main : Launcher Value Game.World
main =
    Launcher.documentWith
        { update = game.update
        , view = game.view
        , subscriptions = game.subscriptions
        , init =
            Decode.decodeValue (Decode.field "url" Decode.string)
                >> Result.withDefault "default.age.bin"
                >> Game.run
        }
