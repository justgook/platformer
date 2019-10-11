module MazePlatformer.Game exposing (main)

import Json.Decode as Decode exposing (Value)
import Logic.Launcher as Launcher exposing (Launcher)
import Logic.Template.Game.Platformer as Game exposing (game)


main : Launcher Value Game.World
main =
    Launcher.document
        { game
            | init =
                Decode.decodeValue (Decode.field "url" Decode.string)
                    >> Result.withDefault "default.age.bin"
                    >> Game.run
        }
