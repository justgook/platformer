module Logic.Template.SaveLoad.Sprite exposing (create, decode, decodeSprite, encode, encodeSprite, extract, read)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component exposing (Spec)
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.Sprite exposing (Sprite, emptyComp)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Loader as Loader exposing (CacheTiled)
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (ExtractAsync, Read(..), TileArg, WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (DecoderWithTexture, GetTexture, Selector(..))
import Logic.Template.SaveLoad.Internal.Util as Util exposing (boolToFloat, hexColor2Vec3)
import Math.Vector2 as Vec2 exposing (vec2)
import Math.Vector3 as Vec3 exposing (vec3)
import Math.Vector4 as Vec4
import Tiled.Level
import Tiled.Tileset exposing (EmbeddedTileData)
import WebGL.Texture exposing (Texture)


encode : Spec Sprite world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, item ) ->
                E.sequence [ E.id id, encodeSprite item ]
            )


encodeSprite : Sprite -> Encoder
encodeSprite item =
    E.sequence
        [ E.xy (Vec2.toRecord item.uP)
        , E.xy (Vec2.toRecord item.uAtlasSize)
        , E.xy (Vec2.toRecord item.uMirror)
        , E.xyz (Vec3.toRecord item.uTransparentColor)
        , E.id item.atlasFirstGid
        , E.xyzw (Vec4.toRecord item.uTileUV)
        ]


decode : Spec Sprite world -> DecoderWithTexture world
decode spec_ getTexture =
    let
        decoder =
            D.map2 Tuple.pair D.id (decodeSprite getTexture)
    in
    D.reverseList decoder
        |> D.map (\list -> spec_.set (Entity.fromList list))


decodeSprite : GetTexture -> Decoder Sprite
decodeSprite getTexture =
    D.succeed
        (\uP uAtlasSize uMirror uTransparentColor atlasFirstGid uTileUV ->
            case getTexture Atlas atlasFirstGid of
                Just uAtlas ->
                    D.succeed
                        { uP = Vec2.fromRecord uP
                        , uAtlas = uAtlas
                        , uAtlasSize = Vec2.fromRecord uAtlasSize
                        , uMirror = Vec2.fromRecord uMirror
                        , uTransparentColor = Vec3.fromRecord uTransparentColor
                        , atlasFirstGid = 0
                        , uTileUV = uTileUV |> Vec4.fromRecord
                        }

                Nothing ->
                    D.fail
        )
        |> D.andMap D.xy
        |> D.andMap D.xy
        |> D.andMap D.xy
        |> D.andMap D.xyz
        |> D.andMap D.id
        |> D.andMap D.xyzw
        |> D.andThen identity


read : Spec Sprite world -> WorldReader world
read spec =
    { defaultRead
        | objectTile = Async (\info -> extract info >> ResourceTask.map (\sprite -> Entity.with ( spec, sprite )))
    }


extract : { a | level : Tiled.Level.Level, gid : Int, x : Float, y : Float, fh : Bool, fv : Bool } -> ExtractAsync Sprite
extract =
    \info ->
        Util.getTilesetByGid (Util.levelCommon info.level).tilesets info.gid
            >> ResourceTask.andThen
                (\t_ ->
                    case t_ of
                        Tiled.Tileset.Embedded t ->
                            Loader.getTextureTiled t.image >> ResourceTask.map (\image -> create t image info)

                        _ ->
                            ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                )


create : EmbeddedTileData -> Texture -> { a | x : Float, y : Float, gid : Int, fh : Bool, fv : Bool } -> Sprite
create t image { x, y, gid, fh, fv } =
    let
        uIndex =
            gid - t.firstgid

        obj_ =
            emptyComp image

        --        grid =
        --            { x = t.imagewidth // t.tilewidth
        --            , y = t.imageheight // t.tileheight
        --            }
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
    obj
