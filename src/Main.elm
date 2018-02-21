module Main exposing (..)

-- import Http

import App.Message exposing (Message)
import App.Model exposing (Model, init)
import App.Subscriptions exposing (subscriptions)
import App.Update exposing (update)
import App.View exposing (view)
import Html
import Json.Decode as Json


main : Program Json.Value Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
