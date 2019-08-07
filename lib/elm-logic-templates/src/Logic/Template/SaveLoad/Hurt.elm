module Logic.Template.SaveLoad.Hurt exposing
    ( decode
    , decodeHit
    , decodeHurt
    , encode
    , encodeHit
    , encodeHurt
    , extractHurtBox
    , read
    )

import AltMath.Vector2 exposing (vec2)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.System exposing (applyIf)
import Logic.Template.Component.Hurt exposing (Circles, Damage, HurtBox(..), HurtWorld, spawnPlayerHurtBox)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (ExtractAsync, Read(..), Reader, TileArg, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (getCollision)
import Tiled.Object exposing (Object(..))


read : Singleton.Spec HurtWorld world -> Reader world
read spec =
    { defaultRead
        | objectTile =
            Async
                (\info ->
                    extractHurtBox info
                        >> ResourceTask.map
                            (\hurt ->
                                \( entityID, world ) ->
                                    --                                    let
                                    --                                        _ =
                                    --                                            hurt |> Debug.log "Logic.Template.SaveLoad.Hurt::read"
                                    --                                    in
                                    --                                    case Maybe.andThen (.objects >> List.head) col of
                                    --                                        Just (Ellipse { kind, width }) ->
                                    --                                            let
                                    --                                                hitPoints =
                                    --                                                    (Util.propertiesWithDefault info).int "hp" 100
                                    --
                                    --                                                offset =
                                    --                                                    vec2 0 0
                                    --                                            in
                                    --                                            ( entityID
                                    --                                            , applyIf
                                    --                                                (kind == "player")
                                    --                                                (Singleton.update spec
                                    --                                                    (spawnPlayerHurtBox ( entityID, ( hitPoints, ( offset, width ) ) ))
                                    --                                                )
                                    --                                                world
                                    --                                            )
                                    --                                        _ ->
                                    ( entityID, world )
                            )
                )
    }


extractHurtBox : ExtractAsync TileArg (Maybe HurtBox)
extractHurtBox tile =
    getCollision tile
        >> ResourceTask.map
            (Maybe.andThen
                (\col ->
                    case List.head col.objects of
                        Just (Ellipse { x, y, kind, width }) ->
                            let
                                hitPoints =
                                    (Util.propertiesWithDefault tile).int "hp" 100

                                r =
                                    width * 0.5

                                offsetFromCenter =
                                    vec2 (x + r - tile.width * 0.5) (tile.height * 0.5 - r - y)
                            in
                            HurtBox hitPoints ( offsetFromCenter, r )
                                |> Just

                        _ ->
                            Nothing
                )
            )


encode : Singleton.Spec HurtWorld world -> world -> Encoder
encode { get } world =
    get world
        |> (\{ playerHitBox, enemyHitBox, playerHurtBox, enemyHurtBox } ->
                E.sequence
                    [ playerHitBox |> encodeHit
                    , enemyHitBox |> encodeHit
                    , playerHurtBox |> encodeHurt
                    , enemyHurtBox |> encodeHurt
                    ]
           )


encodeHit : Component.Set ( Int, Circles ) -> Encoder
encodeHit =
    Entity.toList
        >> E.list (\( id, ( a, ( offset, radius ) ) ) -> E.sequence [ E.id id, E.id a, E.xy offset, E.float radius ])


encodeHurt : Component.Set HurtBox -> Encoder
encodeHurt =
    Entity.toList
        >> E.list
            (\( id, HurtBox a ( offset, radius ) ) ->
                E.sequence [ E.id id, E.id a, E.xy offset, E.float radius ]
            )


decode : Singleton.Spec HurtWorld world -> WorldDecoder world
decode spec =
    D.succeed HurtWorld
        |> D.andMap decodeHit
        |> D.andMap decodeHit
        |> D.andMap decodeHurt
        |> D.andMap decodeHurt
        |> D.map (always >> Singleton.update spec)


decodeHit : Decoder (Component.Set ( Damage, Circles ))
decodeHit =
    D.list (D.map4 (\id a offset radius -> ( id, ( a, ( offset, radius ) ) )) D.id D.id D.xy D.float)
        |> D.map Entity.fromList


decodeHurt : Decoder (Component.Set HurtBox)
decodeHurt =
    D.list
        (D.map4
            (\id hp offset radius ->
                ( id, HurtBox hp ( offset, radius ) )
            )
            D.id
            D.id
            D.xy
            D.float
        )
        |> D.map Entity.fromList
