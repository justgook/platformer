module Main exposing (..)

-- import Http

import App.Message exposing (Message)
import App.Model exposing (Model, init, model)
import App.Subscriptions exposing (subscriptions)
import App.Update exposing (update)
import App.View exposing (view)
import Html exposing (div, text)
import Json.Decode as Json


main : Program Json.Value Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- getBooks : Http.Request (List String)
-- getBooks =
--     Debug.log "" <| Http.get "http://localhost:8080/levels/level1/level.json" (list string)
