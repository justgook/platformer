module World.Component.ImageLayer exposing (imageLayer)

import Defaults exposing (default)
import Dict
import Layer
import Math.Vector2 exposing (vec2)
import ResourceTask
import Tiled.Util2
import WebGL.Texture


imageLayer imageData =
    let
        props =
            Tiled.Util2.properties imageData
    in
    ResourceTask.getTexture ("/assets/" ++ imageData.image)
        >> ResourceTask.map
            (\t ->
                let
                    ( width, height ) =
                        WebGL.Texture.size t
                in
                Layer.Image
                    { image = t
                    , size = vec2 (toFloat width) (toFloat height)
                    , transparentcolor = props.color "transparentcolor" default.transparentcolor
                    , scrollRatio = Tiled.Util2.scrollRatio (Dict.get "scrollRatio" imageData.properties == Nothing) props
                    }
            )
