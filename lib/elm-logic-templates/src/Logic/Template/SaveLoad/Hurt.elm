module Logic.Template.SaveLoad.Hurt exposing
    ( decode
    , decodeHit
    , decodeHurt
    , encode
    , encodeHit
    , encodeHurt
    , extractHurtBox
    , readPlayerHurt
    )

import AltMath.Vector2 exposing (vec2)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component as Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Component.Hurt exposing (Circles, HitBox, HurtBox(..), HurtWorld, spawnPlayerHurtBox)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader exposing (ExtractAsync, GuardReader, Read(..), TileArg, WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util exposing (getCollision)
import Tiled.Object exposing (Object(..))


readPlayerHurt : Singleton.Spec HurtWorld world -> WorldReader world
readPlayerHurt spec =
    { defaultRead
        | objectTile =
            Async
                (\info ->
                    extractHurtBox info
                        >> ResourceTask.map
                            (\hurt_ ->
                                \( entityID, world ) ->
                                    case hurt_ of
                                        Just hurt ->
                                            ( entityID, Singleton.update spec (spawnPlayerHurtBox ( entityID, hurt )) world )

                                        Nothing ->
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
                        Just (Ellipse { x, y, width }) ->
                            let
                                r =
                                    width * 0.5

                                offsetFromCenter =
                                    vec2 (x + r - tile.width * 0.5) (tile.height * 0.5 - r - y)
                            in
                            HurtBox ( offsetFromCenter, r )
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


encodeHit : Component.Set HitBox -> Encoder
encodeHit =
    Entity.toList
        >> E.list (\( id, ( offset, radius ) ) -> E.sequence [ E.id id, E.xy offset, E.float radius ])


encodeHurt : Component.Set HurtBox -> Encoder
encodeHurt =
    Entity.toList
        >> E.list
            (\( id, HurtBox ( offset, radius ) ) ->
                E.sequence [ E.id id, E.xy offset, E.float radius ]
            )


decode : Singleton.Spec HurtWorld world -> WorldDecoder world
decode spec =
    D.succeed HurtWorld
        |> D.andMap decodeHit
        |> D.andMap decodeHit
        |> D.andMap decodeHurt
        |> D.andMap decodeHurt
        |> D.map (always >> Singleton.update spec)


decodeHit : Decoder (Component.Set HitBox)
decodeHit =
    D.list (D.map3 (\id offset radius -> ( id, ( offset, radius ) )) D.id D.xy D.float)
        |> D.map Entity.fromList


decodeHurt : Decoder (Component.Set HurtBox)
decodeHurt =
    D.list
        (D.map3
            (\id offset radius ->
                ( id, HurtBox ( offset, radius ) )
            )
            D.id
            D.xy
            D.float
        )
        |> D.map Entity.fromList
