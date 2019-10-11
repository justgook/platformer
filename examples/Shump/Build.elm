module Shump.Build exposing (main)

import Build exposing (build)
import Json.Decode exposing (Value)
import Logic.Template.Game.ShootEmUp as Game


main : Program Value () (Maybe String)
main =
    build Game.encode
