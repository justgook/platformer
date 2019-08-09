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
import Logic.Template.Component.Hurt exposing (Circles, HitBox, HurtBox, HurtWorld, spawnPlayerHurtBox)
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
                (.objects
                    >> List.foldl
                        (\item acc ->
                            case item of
                                Ellipse { x, y, width } ->
                                    let
                                        r =
                                            width * 0.5
                                    in
                                    ( vec2 (x + r - tile.width * 0.5) (tile.height * 0.5 - r - y), r ) :: acc

                                _ ->
                                    acc
                        )
                        []
                    >> (\l ->
                            if List.isEmpty l then
                                Nothing

                            else
                                Just l
                       )
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
        >> E.list
            (\( id, shapes ) ->
                E.sequence [ E.id id, E.list encodeCircle shapes ]
            )


encodeCircle ( offset, radius ) =
    E.sequence [ E.xy offset, E.float radius ]


encodeHurt : Component.Set HurtBox -> Encoder
encodeHurt =
    encodeHit


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
    D.list (D.map2 (\id shapes -> ( id, shapes )) D.id (D.list decodeCircle))
        |> D.map Entity.fromList


decodeHurt : Decoder (Component.Set HurtBox)
decodeHurt =
    decodeHit


decodeCircle =
    D.map2 Tuple.pair D.xy D.float
