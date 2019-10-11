module RPG.Build exposing (main)

import Build exposing (build)
import Json.Decode exposing (Value)
import Logic.Template.Game.TopDown as Game


main : Program Value () (Maybe String)
main =
    build Game.encode
