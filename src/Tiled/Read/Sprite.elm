module Tiled.Read.Sprite exposing (read)

import Defaults exposing (default)
import Error exposing (Error(..))
import Image
import Image.BMP exposing (encodeWith)
import Logic.Entity as Entity
import Math.Vector2 exposing (vec2)
import ResourceTask
import Tiled.Read exposing (Read(..), defaultRead)
import Tiled.Read.Util exposing (boolToFloat)
import Tiled.Tileset
import Tiled.Util exposing (animationFraming, hexColor2Vec3)
import World.Component.Sprite exposing (Sprite(..))


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
                                        case Tiled.Util.animation t tileIndex of
                                            Just anim ->
                                                ResourceTask.getTexture t.image
                                                    >> ResourceTask.andThen
                                                        (\tileSetImage ->
                                                            let
                                                                animLutData =
                                                                    animationFraming anim

                                                                animLength =
                                                                    List.length animLutData
                                                            in
                                                            ResourceTask.getTexture (encodeWith Image.defaultOptions animLength 1 animLutData)
                                                                >> ResourceTask.map
                                                                    (\animLUT ->
                                                                        let
                                                                            obj =
                                                                                Animated
                                                                                    { x = x
                                                                                    , y = y
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
                                                                                    , transparentcolor = Maybe.withDefault default.transparentcolor (hexColor2Vec3 t.transparentcolor)
                                                                                    }
                                                                        in
                                                                        Entity.with ( spec, obj )
                                                                    )
                                                        )

                                            Nothing ->
                                                ResourceTask.getTexture t.image
                                                    >> ResourceTask.map
                                                        (\tileSetImage ->
                                                            let
                                                                obj =
                                                                    Sprite
                                                                        { x = x
                                                                        , y = y
                                                                        , width = width
                                                                        , height = height
                                                                        , tileIndex = toFloat tileIndex
                                                                        , tileSet = tileSetImage
                                                                        , tileSetSize = vec2 (toFloat t.imagewidth) (toFloat t.imageheight)
                                                                        , tileSize = vec2 (toFloat t.tilewidth) (toFloat t.tileheight)
                                                                        , mirror = vec2 (boolToFloat fh) (boolToFloat fv)
                                                                        , scrollRatio = vec2 1 1
                                                                        , transparentcolor = Maybe.withDefault default.transparentcolor (hexColor2Vec3 t.transparentcolor)
                                                                        }
                                                            in
                                                            Entity.with ( spec, obj )
                                                        )

                                    _ ->
                                        ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                            )
                )
    }
