module PresentationBuild exposing (main)

import Build exposing (build)
import Json.Decode as Decode exposing (Value)
import Logic.Template.Game.Presentation as Presentation


main : Program Value () (Maybe String)
main =
    build Presentation.encode
