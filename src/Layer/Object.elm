module Layer.Object exposing (Object(..))

import Layer.Common as Common exposing (Layer(..))
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile


type Object
    = Static
    | Rectangle (Common.Individual Layer.Object.Rectangle.Model)
    | Ellipse (Common.Individual Layer.Object.Ellipse.Model)
    | Tile (Common.Individual Layer.Object.Tile.Model)
