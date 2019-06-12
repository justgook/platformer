module Logic.Template.SaveLoad.Sprite exposing (decode, encode, read)

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
import Math.Vector4 as Vec4
import Tiled.Tileset


encode : Spec Sprite world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, item ) ->
                E.sequence
                    [ E.id id
                    , E.xy (Vec2.toRecord item.uP)
                    , E.xy (Vec2.toRecord item.uAtlasSize)
                    , E.xy (Vec2.toRecord item.uMirror)
                    , E.xyz (Vec3.toRecord item.uTransparentColor)
                    , E.id item.atlasFirstGid
                    , E.xyzw (Vec4.toRecord item.uTileUV)
                    ]
            )


decode : Spec Sprite world -> DecoderWithTexture world
decode spec_ getTexture =
    let
        decoder =
            D.succeed
                (\uTileUV atlasFirstGid uTransparentColor uMirror uAtlasSize uP id ->
                    case getTexture Atlas atlasFirstGid of
                        Just uAtlas ->
                            D.succeed
                                ( id
                                , { uP = Vec2.fromRecord uP
                                  , uAtlas = uAtlas
                                  , uAtlasSize = Vec2.fromRecord uAtlasSize
                                  , uMirror = Vec2.fromRecord uMirror
                                  , uTransparentColor = Vec3.fromRecord uTransparentColor
                                  , atlasFirstGid = 0
                                  , uTileUV = uTileUV |> Vec4.fromRecord
                                  }
                                )

                        Nothing ->
                            D.fail
                )
                |> D.andMap D.xyzw
                |> D.andMap D.id
                |> D.andMap D.xyz
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.id
                |> D.andThen identity
    in
    D.list decoder
        |> D.map (\list -> spec_.set (Entity.fromList list))


read : Spec Sprite world -> Reader world
read spec =
    { defaultRead
        | objectTile =
            Async
                (\{ x, y, gid, fh, fv, getTilesetByGid } ->
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

                                                        grid =
                                                            { x = t.imagewidth // t.tilewidth
                                                            , y = t.imageheight // t.tileheight
                                                            }

                                                        tileUV =
                                                            Util.tileUV t uIndex

                                                        obj =
                                                            { obj_
                                                                | uP = vec2 x y
                                                                , uAtlasSize = vec2 (toFloat t.imagewidth) (toFloat t.imageheight)
                                                                , uMirror = vec2 (boolToFloat fh) (boolToFloat fv)
                                                                , uTransparentColor = Maybe.withDefault (vec3 1 0 1) (hexColor2Vec3 t.transparentcolor)
                                                                , atlasFirstGid = t.firstgid
                                                                , uTileUV = tileUV
                                                            }
                                                    in
                                                    Entity.with ( spec, obj )
                                                )

                                    _ ->
                                        ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                            )
                )
    }
