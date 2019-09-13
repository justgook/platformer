module Logic.Template.SaveLoad.Ammo exposing (decode, decodeItem, encode, encodeItem, extract, read)

import AltMath.Vector2 as Vec2
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Dict
import Logic.Component exposing (Spec)
import Logic.Entity as Entity
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (ExtractAsync, Read(..), TileData, WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (DecoderWithTexture, GetTexture)
import Logic.Template.SaveLoad.Sprite as Sprite exposing (decodeSprite, encodeSprite)
import Parser exposing ((|.), (|=))
import Set
import Tiled.Properties exposing (Property(..))


read : Spec Ammo world -> WorldReader world
read spec =
    { defaultRead
        | objectTile =
            Async
                (\info ->
                    let
                        task =
                            extract info
                    in
                    task
                        >> ResourceTask.map
                            (\ammo ( entityID, world ) ->
                                if ammo == Ammo.emptyComp then
                                    ( entityID, world )

                                else
                                    Entity.with ( spec, ammo ) ( entityID, world )
                            )
                )
    }


extract : TileData -> ExtractAsync Ammo
extract =
    \({ properties } as info) ->
        let
            var =
                Parser.variable
                    { start = Char.isAlphaNum
                    , inner = \c -> Char.isAlphaNum c || c == '_'
                    , reserved = Set.empty
                    }

            ammoKeyParser =
                Parser.succeed
                    (\name index f -> f name index)
                    |. Parser.keyword "ammo"
                    |. Parser.symbol "."
                    |= var
                    |= Parser.oneOf
                        [ Parser.succeed identity |. Parser.symbol "[" |= Parser.int |. Parser.symbol "]"
                        , Parser.succeed 0
                        ]
                    |. Parser.symbol "."
                    |= Parser.oneOf
                        [ Parser.map (\_ -> Id) (Parser.keyword "id")
                        , Parser.map (\_ -> Tileset) (Parser.keyword "tileset")
                        , Parser.map (\_ -> FireRate) (Parser.keyword "firerate")
                        , Parser.map (\_ -> OffsetX) (Parser.keyword "offset.x")
                        , Parser.map (\_ -> OffsetY) (Parser.keyword "offset.y")
                        , Parser.map (\_ -> VelocityX) (Parser.keyword "velocity.x")
                        , Parser.map (\_ -> VelocityY) (Parser.keyword "velocity.y")
                        , Parser.map (\_ -> Damage) (Parser.keyword "damage")
                        ]
                    |. Parser.end

            emptyInfo =
                { offset = { x = 0, y = 0 }
                , velocity = { x = 0, y = 0 }
                , fireRate = 0
                , firstGid = 0
                , tileId = 0
                , damage = 1
                }

            setProp f value =
                case value of
                    Just item ->
                        Just (f item)

                    Nothing ->
                        Just (f emptyInfo)
        in
        Dict.foldl
            (\k v_ acc ->
                case ( Parser.run ammoKeyParser k, v_ ) of
                    ( Ok (FireRate name index), PropInt fireRate ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | fireRate = fireRate }))
                            acc

                    ( Ok (Tileset name index), PropInt firstGid ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | firstGid = firstGid }))
                            acc

                    ( Ok (Id name index), PropInt tileId ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | tileId = tileId }))
                            acc

                    ( Ok (OffsetX name index), PropFloat offsetX ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | offset = Vec2.setX offsetX a.offset }))
                            acc

                    ( Ok (OffsetY name index), PropFloat offsetY ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | offset = Vec2.setY offsetY a.offset }))
                            acc

                    ( Ok (VelocityX name index), PropFloat velocityX ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | velocity = Vec2.setX velocityX a.velocity }))
                            acc

                    ( Ok (VelocityY name index), PropFloat velocityY ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | velocity = Vec2.setY velocityY a.velocity }))
                            acc

                    ( Ok (Damage name index), PropInt damage ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | damage = damage }))
                            acc

                    _ ->
                        acc
            )
            Dict.empty
            properties
            |> Dict.toList
            |> List.foldl
                (\( ( name, _ ), item ) acc ->
                    acc
                        >> ResourceTask.andThen
                            (\ammo ->
                                Sprite.extract { info | gid = item.tileId + item.firstGid }
                                    >> ResourceTask.map
                                        (\sprite ->
                                            --http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html
                                            ammo
                                                |> Ammo.add name
                                                    { sprite = sprite
                                                    , offset = item.offset
                                                    , velocity = item.velocity
                                                    , fireRate = item.fireRate
                                                    , damage = item.damage
                                                    }
                                        )
                            )
                )
                (ResourceTask.succeed Ammo.emptyComp)


type Key
    = Id String Int
    | Tileset String Int
    | FireRate String Int
    | OffsetX String Int
    | OffsetY String Int
    | VelocityX String Int
    | VelocityY String Int
    | Damage String Int


encode : Spec Ammo world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list (\( id, ammo ) -> E.sequence [ E.id id, encodeItem ammo ])


encodeItem : Ammo -> Encoder
encodeItem ammo =
    Ammo.toList ammo
        |> E.list
            (\( key, template ) ->
                E.sequence
                    [ E.sizedString key
                    , E.list
                        (\content ->
                            E.sequence
                                [ encodeSprite content.sprite
                                , E.xy content.offset
                                , E.xy content.velocity
                                , E.id content.fireRate
                                , E.id content.damage
                                ]
                        )
                        template
                    ]
            )


decode : Spec Ammo world -> DecoderWithTexture world
decode spec getTexture =
    let
        decodeDict =
            decodeItem getTexture
    in
    D.components decodeDict |> D.map spec.set


decodeItem : GetTexture -> Decoder Ammo
decodeItem getTexture =
    let
        decodeTemplate =
            D.succeed
                (\sprite offset velocity fireRate damage ->
                    { sprite = sprite
                    , offset = offset
                    , velocity = velocity
                    , fireRate = fireRate
                    , damage = damage
                    }
                )
                |> D.andMap (decodeSprite getTexture)
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.id
                |> D.andMap D.id

        decodeTemplateList =
            D.reverseList decodeTemplate
    in
    D.reverseList (D.map2 Tuple.pair D.sizedString decodeTemplateList)
        |> D.map Ammo.fromList
