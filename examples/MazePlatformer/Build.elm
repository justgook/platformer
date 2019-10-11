module MazePlarformer.Build exposing (main)

import Build exposing (build)
import Json.Decode as Decode exposing (Value)
import Logic.Template.Game.Platformer as Game


main : Program Value () (Maybe String)
main =
    build Game.encode
