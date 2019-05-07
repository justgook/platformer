module Logic.Asset exposing (Sprite)

import Logic.Asset.Input
import Logic.Asset.Layer
import Logic.Asset.Physics
import Logic.Asset.Sprite


type alias Sprite =
    Logic.Asset.Sprite.Sprite


type alias Input =
    Logic.Asset.Input.Direction


type alias Layer =
    Logic.Asset.Layer.Layer


type alias Physics =
    Logic.Asset.Physics.World
