module Game.PostDecoder.TileLayer exposing (parse)

import Dict exposing (Dict)
import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape as Collision
import Game.Logic.Component as Component
import Game.Logic.World as World
import Game.Model as Model exposing (LoaderData(..))
import Game.PostDecoder.Helpers
    exposing
        ( hexColor2Vec3
        , repeat
        , scrollRatio
        , shapeById
        , tileSetInfo
        )
import Math.Vector2 as Vec2 exposing (vec2)
import Math.Vector3 exposing (vec3)
import Tiled.Decode as Tiled
import Image.BMP exposing (encode24)


parse : Tiled.Level -> World.CollisionMap -> Tiled.TileLayerData -> Result String ( Model.Data String, World.CollisionMap, Dict.Dict String String )
parse { tilesets, tileheight, tilewidth } collisionMap data =
    case tileSetInfo tilesets data.data |> Dict.values of
        tileset :: [] ->
            let
                start =
                    vec2 (toFloat tilewidth / 2) (toFloat tileheight / 2)

                relative2absolute index { p, xw, yw } =
                    let
                        y =
                            (toFloat index / toFloat data.width)
                                |> floor
                                |> (-) (data.height - 1)
                                |> (*) tileheight
                                |> toFloat
                                |> (+) (toFloat tileheight - Vec2.getY p - Vec2.getY yw)

                        x =
                            (index % data.width)
                                |> (*) tilewidth
                                |> toFloat
                                |> (+) (Vec2.getX xw)
                                |> (+) (Vec2.getX p)
                    in
                        vec2 x y

                newCollisionMap =
                    data.data
                        |> indexedFoldr
                            (\i id_ acc_ ->
                                let
                                    id =
                                        id_ - tileset.firstgid
                                in
                                    if id < 0 then
                                        acc_
                                    else
                                        case shapeById (relative2absolute i) id tileset.tiles of
                                            Just item ->
                                                Collision.insert
                                                    { boundingBox = Collision.aabbData { shape = item } |> Collision.createAABBData
                                                    , effect = Component.SolidEffect
                                                    }
                                                    acc_

                                            Nothing ->
                                                acc_
                            )
                            collisionMap
            in
                Ok
                    ( Model.TileLayer1
                        { lutTexture = "Layer.Data-USE INDEX::" ++ data.name
                        , tileSetTexture = tileset.image
                        , firstgid = tileset.firstgid
                        , lutSize = vec2 (toFloat data.width) (toFloat data.height)
                        , tileSetSize = vec2 (toFloat tileset.imagewidth / toFloat tileset.tilewidth) (toFloat tileset.imageheight / toFloat tileset.tileheight)
                        , transparentcolor = hexColor2Vec3 tileset.transparentcolor |> Result.withDefault (vec3 1.0 0.0 1.0)
                        , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                        , scrollRatio = scrollRatio data
                        , repeat = repeat data
                        }
                    , newCollisionMap
                    , Dict.empty
                        |> Dict.insert tileset.image tileset.image
                        |> Dict.insert ("Layer.Data-USE INDEX::" ++ data.name) (encode24 data.width data.height data.data)
                    )

        [] ->
            Err ("No tileset found for Tile layer (" ++ data.name ++ ")")

        _ ->
            Err "Multiple tileset for one layer not yet supported"


{-| Variant of `foldr` that passes the index of the current element to the step function. `indexedFoldr` is to `List.foldr` as `List.indexedMap` is to `List.map`.
-}
indexedFoldr : (Int -> a -> b -> b) -> b -> List a -> b
indexedFoldr func acc list =
    -- http://package.elm-lang.org/packages/elm-community/list-extra/7.1.0/List-Extra#indexedFoldr
    let
        step x ( i, acc_ ) =
            ( i - 1, func i x acc_ )
    in
        Tuple.second (List.foldr step ( List.length list - 1, acc ) list)
