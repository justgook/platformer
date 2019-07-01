module Logic.Template.SaveLoad.Ammo exposing (extract, read)

import AltMath.Vector2 as Vec2
import Dict
import Logic.Component exposing (Spec)
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Sprite as Sprite
import Parser exposing ((|.), (|=))
import Set
import Tiled.Properties exposing (Property(..))
import Tiled.Tileset as Tileset


read : Spec Ammo world -> Reader world
read spec =
    { defaultRead
        | objectTile =
            Async
                (\({ properties, gid, getTilesetByGid, fh, fv } as info) ->
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


extract =
    \({ properties, gid, getTilesetByGid, fh, fv } as info) ->
        let
            var =
                Parser.variable
                    { start = Char.isAlphaNum
                    , inner = \c -> Char.isAlphaNum c || c == '_'
                    , reserved = Set.empty
                    }

            ammoKeyParser =
                Parser.succeed
                    (\name f index -> f name index)
                    |. Parser.keyword "ammo"
                    |. Parser.symbol "."
                    |= var
                    |. Parser.symbol "."
                    |= Parser.oneOf
                        [ Parser.map (\_ -> Id) (Parser.keyword "id")
                        , Parser.map (\_ -> Tileset) (Parser.keyword "tileset")
                        , Parser.map (\_ -> FireRate) (Parser.keyword "firerate")
                        , Parser.map (\_ -> OffsetX) (Parser.keyword "offset.x")
                        , Parser.map (\_ -> OffsetY) (Parser.keyword "offset.y")
                        , Parser.map (\_ -> VelocityX) (Parser.keyword "velocity.x")
                        , Parser.map (\_ -> VelocityY) (Parser.keyword "velocity.y")
                        ]
                    |= Parser.oneOf
                        [ Parser.succeed identity |. Parser.symbol "[" |= Parser.int |. Parser.symbol "]"
                        , Parser.succeed 0
                        ]
                    |. Parser.end

            emptyInfo =
                { offset = { x = 0, y = 0 }
                , velocity = { x = 0, y = 0 }
                , fireRate = 0
                , firstGid = 0
                , uIndex = 0
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

                    ( Ok (Id name index), PropInt ammoGid ) ->
                        Dict.update ( name, index )
                            (setProp (\a -> { a | uIndex = ammoGid }))
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
                                getTilesetByGid item.firstGid
                                    >> ResourceTask.andThen
                                        (\t_ ->
                                            case t_ of
                                                Tileset.Embedded t ->
                                                    Loader.getTextureTiled t.image
                                                        >> ResourceTask.map (\texture -> ( t, texture ))

                                                _ ->
                                                    ResourceTask.fail (Error 10001 "Cannot read Ammo info from not Tileset.Embedded")
                                        )
                                    >> ResourceTask.map
                                        (\( t, image ) ->
                                            --http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html
                                            ammo
                                                |> Ammo.add name
                                                    { sprite = Sprite.create t image { info | gid = item.uIndex + t.firstgid }
                                                    , offset = item.offset
                                                    , velocity = item.velocity
                                                    , fireRate = item.fireRate
                                                    }
                                        )
                            )
                )
                (ResourceTask.succeed Dict.empty)


type Key
    = Id String Int
    | Tileset String Int
    | FireRate String Int
    | OffsetX String Int
    | OffsetY String Int
    | VelocityX String Int
    | VelocityY String Int



--encode : Spec Bullet world -> world -> Encoder
--encode { get } world =
--    Entity.toList (get world)
--        |> E.list (\( id, item ) -> E.sequence [ E.id id, E.xy item ])
--
--
--decode : Spec Bullet world -> WorldDecoder world
--decode spec =
--    let
--        decoder =
--            D.map2 Tuple.pair D.id D.xy
--    in
--    D.list decoder
--        |> D.map (\list -> spec.set (Entity.fromList list))
