module World.Component.Sprite exposing (Sprite(..), empty, spec)

import Layer.Common as Common
import Layer.Object.Animated
import Layer.Object.Tile
import Logic.Component


type Sprite
    = Sprite (Common.Individual Layer.Object.Tile.Model)
    | Animated (Common.Individual Layer.Object.Animated.Model)


spec =
    { get = .sprites
    , set = \comps world -> { world | sprites = comps }
    }


empty =
    Logic.Component.empty
