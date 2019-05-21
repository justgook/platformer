module Logic.Template.SaveLoad.Layer.ImageLayer exposing (imageLayer)

import Dict
import Logic.Template.Component.Layer as Layer exposing (Layer(..))
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (ReaderTask)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.Util as Util
import Math.Vector2 exposing (vec2)
import Math.Vector3 exposing (vec3)
import Tiled.Layer exposing (ImageData)
import WebGL.Texture


imageLayer : ImageData -> ReaderTask Layer
imageLayer imageData =
    let
        props =
            Util.properties imageData
    in
    Reader.getTexture imageData.image
        >> ResourceTask.map
            (\t ->
                let
                    ( width, height ) =
                        WebGL.Texture.size t
                in
                { image = t
                , size = vec2 (toFloat width) (toFloat height)
                , transparentcolor = props.color "transparentcolor" (vec3 1 0 1)
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
