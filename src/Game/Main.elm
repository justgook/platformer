module Game.Main exposing (load)

import Game.Message exposing (Message(..))
import Game.PostDecoder exposing (decode)
import Http


load : String -> Cmd Message
load url =
    let
        prefix =
            String.split "/" url
                |> init
                |> Maybe.withDefault []
                |> String.join "/"
                |> flip (++) "/"
    in
        decode prefix
            |> Http.get url
            |> Http.send LevelLoaded


{-| <http://package.elm-lang.org/packages/elm-community/list-extra/7.1.0/List-Extra#init>
-}
init : List a -> Maybe (List a)
init items =
    case items of
        [] ->
            Nothing

        nonEmptyList ->
            nonEmptyList
                |> List.reverse
                |> List.tail
                |> Maybe.map List.reverse
