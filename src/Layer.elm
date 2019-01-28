module Layer exposing (Layer(..))

import Layer.Common as Common
import Layer.Image
import Layer.Object exposing (Object)
import Layer.Tiles
import Logic.Component as Component


type Layer
    = Tiles (Common.Individual Layer.Tiles.Model)
    | Image (Common.Individual Layer.Image.Model)
    | Object (Component.Set Object)
