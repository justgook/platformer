module Logic.Template.Component.LevelSize exposing (LevelSize, empty, spec)

import Logic.Component.Singleton as Singleton


empty : LevelSize
empty =
    { width = 1
    , height = 1
    }


spec : Singleton.Spec LevelSize { world | levelSize : LevelSize }
spec =
    Singleton.Spec .levelSize (\b a -> { a | levelSize = b })


type alias LevelSize =
    { width : Int
    , height : Int
    }
