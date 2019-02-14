module Layer exposing (Layer(..))

import Layer.Common as Common
import Layer.Image
import Layer.Tiles
import Layer.Tiles.Animated


type Layer object
    = Tiles (Common.Individual Layer.Tiles.Model)
    | AbimatedTiles (Common.Individual Layer.Tiles.Animated.Model)
    | Image (Common.Individual Layer.Image.Model)
    | Object object
