module PlatformerBuild exposing (main)

import Build exposing (build)
import Json.Decode as Decode exposing (Value)
import Logic.Template.Game.Platformer as Platformer


main : Program Value () (Maybe String)
main =
    build Platformer.encode
