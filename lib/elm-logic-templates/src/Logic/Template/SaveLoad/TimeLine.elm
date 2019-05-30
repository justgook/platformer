module Logic.Template.SaveLoad.TimeLine exposing (decode, decodeSimple, encode, encodeSimple, read)

import Bytes exposing (Endianness(..))
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component exposing (Spec)
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.TimeLine exposing (Frame, Simple, emptyComp, get, spec)
import Logic.Template.Internal
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), Reader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (animationFraming)
import Math.Vector2 as Vec2
import Tiled.Tileset


encode : Spec Simple world -> world -> Encoder
encode { get } world =
    Entity.toList (get world)
        |> E.list
            (\( id, item ) ->
                E.sequence
                    [ E.unsignedInt32 BE id
                    , encodeSimple item
                    ]
            )


decode : Spec Simple world -> WorldDecoder world
decode spec_ =
    let
        decoder =
            D.map2
                (\id item ->
                    ( id, item )
                )
                (D.unsignedInt32 BE)
                decodeSimple
    in
    D.list decoder
        |> D.map
            (\list -> Singleton.update spec_ (\_ -> Entity.fromList list))


encodeSimple : Simple -> Encoder
encodeSimple item =
    E.sequence
        [ E.list E.float (Logic.Template.Internal.toList item.timeline)
        , E.xy (Vec2.toRecord item.uMirror)
        ]


decodeSimple : Decoder Simple
decodeSimple =
    D.map2
        (\i uMirror ->
            emptyComp i |> (\a -> { a | uMirror = Vec2.fromRecord uMirror })
        )
        (D.list D.float)
        D.xy


read : Spec Simple world -> Reader world
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
                                                let
                                                    index =
                                                        gid - t.firstgid
                                                in
                                                case Util.animation t index |> Maybe.map (animationFraming >> List.map toFloat >> emptyComp) of
                                                    Just obj ->
                                                        Entity.with ( spec, obj ) ( entityID, world )

                                                    Nothing ->
                                                        ( entityID, world )
                                            )

                                    _ ->
                                        ResourceTask.fail (Error 6002 "object tile readers works only with single image tilesets")
                            )
                )
    }
