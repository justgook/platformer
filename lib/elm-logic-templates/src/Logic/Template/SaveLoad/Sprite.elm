module Logic.Template.SaveLoad.Sprite exposing (decode, encode, read)

import Bytes exposing (Endianness(..))
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component exposing (Spec)
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.Sprite exposing (Sprite, emptyComp)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (DecoderWithTexture, Selector(..))
import Logic.Template.SaveLoad.Internal.Util as Util exposing (boolToFloat, hexColor2Vec3)
import Math.Vector2 as Vec2 exposing (vec2)
import Math.Vector3 as Vec3 exposing (vec3)
import Tiled.Tileset


encode : Spec Sprite world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, item ) ->
                E.sequence
                    [ E.unsignedInt32 BE id
                    , E.xy (Vec2.toRecord item.uP)
                    , E.xy (Vec2.toRecord item.uDimension)
                    , E.float item.uIndex

                    -- uAtlas
                    , E.xy (Vec2.toRecord item.uAtlasSize)
                    , E.xy (Vec2.toRecord item.uTileSize)
                    , E.xy (Vec2.toRecord item.uMirror)
                    , E.xyz (Vec3.toRecord item.transparentcolor)
                    ]
            )


decode : Spec Sprite world -> DecoderWithTexture world
decode spec_ getTexture =
    let
        decoder =
            D.succeed
                (\transparentcolor uMirror uTileSize uAtlasSize uIndex uDimension uP id ->
                    case getTexture Atlas (round uIndex) of
                        Just uAtlas ->
                            D.succeed
                                ( id
                                , { uP = Vec2.fromRecord uP
                                  , uDimension = Vec2.fromRecord uDimension
                                  , uIndex = uIndex
                                  , uAtlas = uAtlas
                                  , uAtlasSize = Vec2.fromRecord uAtlasSize
                                  , uTileSize = Vec2.fromRecord uTileSize
                                  , uMirror = Vec2.fromRecord uMirror
                                  , transparentcolor = Vec3.fromRecord transparentcolor
                                  }
                                )

                        Nothing ->
                            D.fail
                )
                |> D.andMap D.xyz
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.float
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap (D.unsignedInt32 BE)
                |> D.andThen identity
    in
    D.list decoder
        --        |> D.map (\list -> Singleton.update spec_ (\_ -> Entity.fromList list))
        |> D.map (\list -> spec_.set (Entity.fromList list))


read : Spec Sprite world -> Reader world
read spec =
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
                                            uIndex =
                                                gid - t.firstgid
                                        in
                                        Loader.getTextureTiled t.image
                                            >> ResourceTask.map
                                                (\tileSetImage ->
                                                    let
                                                        obj_ =
                                                            emptyComp tileSetImage

                                                        obj =
                                                            { obj_
                                                                | uP = vec2 x y
                                                                , uDimension = vec2 width height
                                                                , uIndex = toFloat uIndex
                                                                , uAtlasSize = vec2 (toFloat t.imagewidth) (toFloat t.imageheight)
                                                                , uTileSize = vec2 (toFloat t.tilewidth) (toFloat t.tileheight)
                                                                , uMirror = vec2 (boolToFloat fh) (boolToFloat fv)
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
