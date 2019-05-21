module Logic.Template.SaveLoad.Sprite exposing (read)

import Image
import Image.BMP exposing (encodeWith)
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.Sprite exposing (Sprite(..))
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), ReaderTask, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.Util as Util exposing (animationFraming, hexColor2Vec3)
import Math.Vector2 exposing (vec2)
import Math.Vector3 exposing (vec3)
import Tiled.Tileset


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0


read spec =
    --TODO create other for isometric view
    { defaultRead
        | objectTile =
            Async
                (\{ x, y, width, height, gid, fh, fv, getTilesetByGid } ->
                    getTilesetByGid gid
                        >> ResourceTask.andThen
                            (\t_ ->
                                case t_ of
                                    Tiled.Tileset.Embedded t ->
                                        let
                                            tileIndex =
                                                gid - t.firstgid
                                        in
                                        case Util.animation t tileIndex of
                                            Just anim ->
                                                Reader.getTexture t.image
                                                    >> ResourceTask.andThen
                                                        (\tileSetImage ->
                                                            let
                                                                animLutData =
                                                                    animationFraming anim

                                                                animLength =
                                                                    List.length animLutData
                                                            in
                                                            Reader.getTexture (encodeWith Image.defaultOptions animLength 1 animLutData)
                                                                >> ResourceTask.map
                                                                    (\animLUT ->
                                                                        let
                                                                            obj =
                                                                                Animated
                                                                                    { p = vec2 x y
                                                                                    , start = 0
                                                                                    , width = width
                                                                                    , height = height
                                                                                    , tileSet = tileSetImage
                                                                                    , tileSetSize = vec2 (toFloat t.imagewidth) (toFloat t.imageheight)
                                                                                    , tileSize = vec2 (toFloat t.tilewidth) (toFloat t.tileheight)
                                                                                    , mirror = vec2 (boolToFloat fh) (boolToFloat fv)
                                                                                    , animLUT = animLUT
                                                                                    , animLength = animLength
                                                                                    , scrollRatio = vec2 1 1
                                                                                    , transparentcolor = Maybe.withDefault (vec3 1 0 1) (hexColor2Vec3 t.transparentcolor)
                                                                                    }
                                                                        in
                                                                        Entity.with ( spec, obj )
                                                                    )
                                                        )

                                            Nothing ->
                                                Reader.getTexture t.image
                                                    >> ResourceTask.map
                                                        (\tileSetImage ->
                                                            let
                                                                obj =
                                                                    Sprite
                                                                        { p = vec2 x y
                                                                        , width = width
                                                                        , height = height
                                                                        , tileIndex = toFloat tileIndex
                                                                        , tileSet = tileSetImage
                                                                        , tileSetSize = vec2 (toFloat t.imagewidth) (toFloat t.imageheight)
                                                                        , tileSize = vec2 (toFloat t.tilewidth) (toFloat t.tileheight)
                                                                        , mirror = vec2 (boolToFloat fh) (boolToFloat fv)
                                                                        , scrollRatio = vec2 1 1
                                                                        , transparentcolor = Maybe.withDefault (vec3 1 0 1) (hexColor2Vec3 t.transparentcolor)
                                                                        }
                                                            in
                                                            Entity.with ( spec, obj )
                                                        )

                                    _ ->
                                        ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                            )
                )
    }
