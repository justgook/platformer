module World.Component.ImageLayer exposing (imageLayer)

import Defaults exposing (default)
import Dict
import Layer exposing (Layer)
import Math.Vector2 exposing (vec2)
import ResourceTask
import Tiled.Layer exposing (ImageData)
import Tiled.Util
import WebGL.Texture


imageLayer :
    ImageData
    -> ResourceTask.CacheTask
    -> ResourceTask.ResourceTask Layer
imageLayer imageData =
    let
        props =
            Tiled.Util.properties imageData
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
                , scrollRatio = Tiled.Util.scrollRatio (Dict.get "scrollRatio" imageData.properties == Nothing) props
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



-- type Repeat
--     = Repeat
--     | RepeatX
--     | RepeatY
--     | NoRepeat
-- -- repeat : String -> Repeat -> Repeat
-- -- repeat s d =
-- --
