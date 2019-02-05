module Layer exposing (Layer(..))

import Layer.Common as Common
import Layer.Image
import Layer.Object exposing (Object)
import Layer.Tiles
import Layer.Tiles.Animated
import Logic.Component as Component


type Layer
    = Tiles (Common.Individual Layer.Tiles.Model)
    | AbimatedTiles (Common.Individual Layer.Tiles.Animated.Model)
    | Image (Common.Individual Layer.Image.Model)
    | Object (Component.Set Object)
