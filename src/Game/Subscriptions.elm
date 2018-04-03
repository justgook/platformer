module Game.Subscriptions exposing (subscriptions)

import Game.Logic.Subscriptions as ECS
import Game.Message as Message
import Game.Model as Model exposing (Model)


subscriptions : Model -> Sub Message.Message
subscriptions model =
    case model.renderData of
        Model.Success _ ->
            Sub.map Message.Logic (ECS.subscriptions model)

        _ ->
            Sub.none
