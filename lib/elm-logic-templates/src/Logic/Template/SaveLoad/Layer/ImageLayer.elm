module Logic.Template.SaveLoad.Layer.ImageLayer exposing (ImageLayer, Repeat(..), read)

import Dict
import Logic.Component.Singleton as Singleton
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.Util as Util
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Tiled.Layer exposing (ImageData)
import WebGL.Texture exposing (Texture)


type alias ImageLayer =
    { image : Texture
    , id : Int
    , size : Vec2
    , transparentcolor : Vec3
    , scrollRatio : Vec2
    , repeat : Repeat
    }


type Repeat
    = RepeatX
    | RepeatY
    | RepeatNo
    | Repeat


read : Singleton.Spec (List ImageLayer) world -> Reader world
read { set, get } =
    { defaultRead
        | layerImage =
            Async (\info -> imageLayerNew info >> ResourceTask.map (\parsedLayers ( id, w ) -> ( id, set (get w ++ [ parsedLayers ]) w )))
    }



--Async (\info -> tileLayerNew info


imageLayerNew : ImageData -> Loader.TaskTiled ImageLayer
imageLayerNew imageData =
    let
        props =
            Util.properties imageData
    in
    Loader.getTextureTiled imageData.image
        >> ResourceTask.map
            (\t ->
                let
                    ( width, height ) =
                        WebGL.Texture.size t
                in
                { image = t
                , id = imageData.id
                , size = vec2 (toFloat width) (toFloat height)
                , transparentcolor = props.color "transparentcolor" (vec3 1 0 1)
                , scrollRatio = Util.scrollRatio (Dict.get "scrollRatio" imageData.properties == Nothing) props
                , repeat =
                    case props.string "repeat" "repeat" of
                        "repeat-x" ->
                            RepeatX

                        "repeat-y" ->
                            RepeatY

                        "no-repeat" ->
                            RepeatNo

                        _ ->
                            Repeat
                }
            )
