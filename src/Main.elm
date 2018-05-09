module Main exposing (main)

import App.Message exposing (Message)
import App.Model exposing (Model, init)
import App.Subscriptions exposing (subscriptions)
import App.Update exposing (update)
import App.View exposing (view)
import VirtualDom exposing (programWithFlags)
import Json.Decode as Json


main : Program Json.Value Model Message
main =
    programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
