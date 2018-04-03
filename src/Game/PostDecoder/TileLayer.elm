module Game.PostDecoder.TileLayer exposing (parse)

import Dict
import Game.Logic.Collision.Map as Collision
import Game.Model as Model exposing (LoaderData(..), Model)
import Game.PostDecoder.Helpers
    exposing
        ( findTileSet
        , getFloatProp
        , hexColor2Vec3
        , repeat
        , scrollRatio
        , shapeById
        , tileSetInfo
        )
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Tiled.Decode as Tiled
import Util.BMP exposing (bmp24)


test : Vec2 -> Vec2
test =
    Vec2.add (vec2 1 1)
        >> Vec2.add (vec2 2 2)


parse : Tiled.Level -> Collision.Map -> Tiled.TileLayerData -> Result String ( Model.Data String, Collision.Map, Dict.Dict String String )
parse ({ tilesets, tileheight, tilewidth } as level) collisionMap data =
    case tileSetInfo tilesets data.data |> Dict.values of
        tileset :: [] ->
            let
                start =
                    vec2 (toFloat tilewidth / 2) (toFloat tileheight / 2)

                relative2absolute index =
                    let
                        x =
                            (index % data.width)
                                |> (*) tilewidth
                                |> toFloat

                        y =
                            (toFloat index / toFloat data.width)
                                |> floor
                                |> (-) (data.height - 1)
                                |> (*) tileheight
                                |> toFloat
                    in
                    Vec2.scale 0.5
                        >> Vec2.sub (Vec2.add start (vec2 x y))

                newCollisionMap =
                    data.data
                        |> indexedFoldr
                            (\i id_ acc ->
                                let
                                    id =
                                        id_ - tileset.firstgid
                                in
                                if id < 0 then
                                    acc
                                else
                                    case shapeById (relative2absolute i) id tileset.tiles of
                                        Just item ->
                                            Collision.insert item acc

                                        Nothing ->
                                            acc
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
                    |> Dict.insert ("Layer.Data-USE INDEX::" ++ data.name) (bmp24 data.width data.height data.data)
                )

        data ->
            Err "Multiple tileset for one layer not yet supported"


{-| Variant of `foldr` that passes the index of the current element to the step function. `indexedFoldr` is to `List.foldr` as `List.indexedMap` is to `List.map`.
-}
indexedFoldr : (Int -> a -> b -> b) -> b -> List a -> b
indexedFoldr func acc list =
    -- http://package.elm-lang.org/packages/elm-community/list-extra/7.1.0/List-Extra#indexedFoldr
    let
        step x ( i, acc ) =
            ( i - 1, func i x acc )
    in
    Tuple.second (List.foldr step ( List.length list - 1, acc ) list)
