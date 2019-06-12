module Logic.Template.SaveLoad.TimeLine exposing (decode, decodeItem, durationToFrame, encode, encodeItem, fromTileset, read)

import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component exposing (Spec)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.TimeLine as TimeLine2 exposing (NotSimple, TileUV)
import Logic.Template.Internal.RangeTree as RangeTree exposing (RangeTree)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util
import Math.Vector2 as Vec2
import Math.Vector4 as Vec4 exposing (vec4)
import Tiled.Tileset


read : Spec NotSimple world -> Reader world
read spec =
    { defaultRead
        | objectTile =
            Async
                (\{ gid, getTilesetByGid } ->
                    getTilesetByGid gid
                        >> ResourceTask.andThen
                            (\t_ ->
                                case t_ of
                                    Tiled.Tileset.Embedded t ->
                                        ResourceTask.succeed
                                            (\( entityID, world ) ->
                                                case animationFraming t (gid - t.firstgid) of
                                                    Just timeline ->
                                                        let
                                                            obj =
                                                                TimeLine2.emptyComp timeline
                                                        in
                                                        Entity.with ( spec, obj ) ( entityID, world )

                                                    Nothing ->
                                                        ( entityID, world )
                                            )

                                    _ ->
                                        ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                            )
                )
    }


encode : Spec NotSimple world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, item ) ->
                E.sequence
                    [ E.id id
                    , encodeItem item
                    ]
            )


encodeItem : NotSimple -> Encoder
encodeItem item =
    E.sequence
        [ E.list (\( i, a ) -> E.sequence [ E.id i, a |> Vec4.toRecord |> E.xyzw ]) (RangeTree.toList item.timeline)
        , E.xy (Vec2.toRecord item.uMirror)
        ]


decode : Spec NotSimple world -> WorldDecoder world
decode spec_ =
    let
        decoder =
            D.map2 (\id item -> ( id, item ))
                D.id
                decodeItem
    in
    D.list decoder
        |> D.map
            (\list -> Singleton.update spec_ (\_ -> Entity.fromList list))


decodeItem : Decoder NotSimple
decodeItem =
    D.map2
        (\item uMirror ->
            (case item of
                ( i, r ) :: rest ->
                    RangeTree.fromList i r rest

                [] ->
                    RangeTree.fromList 0 (vec4 0 0 0 0) []
            )
                |> TimeLine2.emptyComp
                |> (\a -> { a | uMirror = Vec2.fromRecord uMirror })
        )
        (D.list
            (D.map2 (\a b -> ( a, Vec4.fromRecord b )) D.id D.xyzw)
        )
        D.xy


durationToFrame duration =
    toFloat duration / 1000 * 60 |> ceiling


fromTileset t uIndex =
    animationFraming t uIndex
        |> Maybe.map TimeLine2.emptyComp


animationFraming : Tiled.Tileset.EmbeddedTileData -> Int -> Maybe (RangeTree TileUV)
animationFraming t uIndex =
    Util.animation t uIndex
        |> Maybe.andThen
            (\anim ->
                case anim of
                    { duration, tileid } :: rest ->
                        let
                            ( _, tree ) =
                                animationFraming_ t rest ( durationToFrame duration, RangeTree.empty (toFloat duration / 1000 * 60 |> ceiling) (Util.tileUV t tileid) )
                        in
                        Just tree

                    [] ->
                        Nothing
            )


animationFraming_ : Tiled.Tileset.EmbeddedTileData -> List { b | duration : Int, tileid : Int } -> ( Int, RangeTree TileUV ) -> ( Int, RangeTree TileUV )
animationFraming_ t anim start =
    anim
        |> List.foldl
            (\{ duration, tileid } ( duration_, acc ) ->
                let
                    newDur =
                        duration_ + durationToFrame duration
                in
                ( newDur
                , acc |> RangeTree.insert newDur (Util.tileUV t tileid)
                )
            )
            start
