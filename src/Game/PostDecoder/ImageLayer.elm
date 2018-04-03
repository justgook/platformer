module Game.PostDecoder.ImageLayer exposing (parse)

import Dict
import Game.Model as Model exposing (Model)
import Game.PostDecoder.Helpers exposing (getFloatProp, hexColor2Vec3, repeat, scrollRatio)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Tiled.Decode as Tiled


parse : Tiled.ImageLayerData -> ( Model.Data String, Dict.Dict String String )
parse data =
    ( Model.ImageLayer
        { x = data.x
        , y = data.y
        , texture = data.image
        , transparentcolor = hexColor2Vec3 data.transparentcolor |> Result.withDefault (vec3 1.0 1.0 1.0)
        , scrollRatio = scrollRatio data
        , repeat = repeat data
        }
    , Dict.empty
        |> Dict.insert data.image data.image
    )
