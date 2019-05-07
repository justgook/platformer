module Logic.Tiled.Read.Layer.ImageLayer exposing (imageLayer)

import Defaults exposing (default)
import Dict
import Logic.Asset.Layer as Layer exposing (Layer)
import Logic.Tiled.ResourceTask as ResourceTask
import Logic.Tiled.Util
import Math.Vector2 exposing (vec2)
import Tiled.Layer exposing (ImageData)
import WebGL.Texture


imageLayer :
    ImageData
    -> ResourceTask.CacheTask
    -> ResourceTask.ResourceTask Layer
imageLayer imageData =
    let
        props =
            Logic.Tiled.Util.properties imageData
    in
    ResourceTask.getTexture imageData.image
        >> ResourceTask.map
            (\t ->
                let
                    ( width, height ) =
                        WebGL.Texture.size t
                in
                { image = t
                , size = vec2 (toFloat width) (toFloat height)
                , transparentcolor = props.color "transparentcolor" default.transparentcolor
                , scrollRatio = Logic.Tiled.Util.scrollRatio (Dict.get "scrollRatio" imageData.properties == Nothing) props
                }
                    |> (case props.string "repeat" "repeat" of
                            "repeat-x" ->
                                Layer.ImageX

                            "repeat-y" ->
                                Layer.ImageY

                            "no-repeat" ->
                                Layer.ImageNo

                            _ ->
                                Layer.Image
                       )
            )
