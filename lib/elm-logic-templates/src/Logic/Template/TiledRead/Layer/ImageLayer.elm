module Logic.Template.TiledRead.Layer.ImageLayer exposing (imageLayer)

import Defaults exposing (default)
import Dict
import Logic.Template.Layer as Layer exposing (Layer(..), draw, empty)
import Logic.Template.TiledRead.Internal.ResourceTask as ResourceTask
import Logic.Template.TiledRead.Internal.Util as Util
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
            Util.properties imageData
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
                , scrollRatio = Util.scrollRatio (Dict.get "scrollRatio" imageData.properties == Nothing) props
                }
                    |> (case props.string "repeat" "repeat" of
                            "repeat-x" ->
                                ImageX

                            "repeat-y" ->
                                ImageY

                            "no-repeat" ->
                                ImageNo

                            _ ->
                                Image
                       )
            )
