module World.Component.Object exposing (Object(..), objects)

import Defaults exposing (default)
import Error exposing (Error(..))
import Layer.Common as Common
import Layer.Object.Animated
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.Component
import Logic.Entity as Entity
import Math.Vector2 exposing (vec2)
import ResourceTask
import Tiled.Tileset
import Tiled.Util
import World.Component.Common exposing (Read(..), defaultRead)


type Object
    = Rectangle (Common.Individual Layer.Object.Rectangle.Model)
    | Ellipse (Common.Individual Layer.Object.Ellipse.Model)
    | Tile (Common.Individual Layer.Object.Tile.Model)
    | Animated (Common.Individual Layer.Object.Animated.Model)


objects =
    --TODO create other for isometric view
    let
        spec =
            { get = .objects
            , set = \comps world -> { world | objects = comps }
            }
    in
    { spec = spec
    , empty = Logic.Component.empty
    , read =
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
                                                        >> ResourceTask.map
                                                            (\tileSetImage ->
                                                                let
                                                                    tilsetProps =
                                                                        Tiled.Util.properties t

                                                                    obj =
                                                                        Animated
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
                                                                            , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
                                                                            }
                                                                in
                                                                Entity.with ( spec, obj )
                                                            )

                                                Nothing ->
                                                    ResourceTask.getTexture t.image
                                                        >> ResourceTask.map
                                                            (\tileSetImage ->
                                                                let
                                                                    tilsetProps =
                                                                        Tiled.Util.properties t

                                                                    obj =
                                                                        Tile
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
                                                                            , transparentcolor = tilsetProps.color "transparentcolor" default.transparentcolor
                                                                            }
                                                                in
                                                                Entity.with ( spec, obj )
                                                            )

                                        _ ->
                                            ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                                )
                    )
        }
    }


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0
