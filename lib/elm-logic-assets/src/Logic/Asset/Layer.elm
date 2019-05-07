module Logic.Asset.Layer exposing (Layer(..), empty)

import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Layer.Tiles.Animated
import Logic.Component


type Layer
    = Tiles (Common.Individual Layer.Tiles.Model)
    | AnimatedTiles (Common.Individual Layer.Tiles.Animated.Model)
    | ImageX (Common.Individual Layer.Image.Model)
    | ImageY (Common.Individual Layer.Image.Model)
    | ImageNo (Common.Individual Layer.Image.Model)
    | Image (Common.Individual Layer.Image.Model)
    | Object (Logic.Component.Set ())


empty : List Layer
empty =
    []


spec =
    { get = .layers
    , set = \comps world -> { world | layers = comps }
    }
