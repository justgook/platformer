module Game.Update exposing (update)

import Game.Message as Message exposing (Message)
import Game.Model exposing (Model)


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Message.LoadLevel (Ok data) ->
            let
                _ =
                    Debug.log "Message.LoadMetadata" data
            in
            ( { model | level = data }, Cmd.none )

        Message.LoadLevel (Err data) ->
            let
                _ =
                    Debug.log "Message.LoadMetadata ERROR" data
            in
            ( model, Cmd.none )
