module Logic.Template.SaveLoad.AudioSprite exposing (decode, encode, read)

import Bytes.Decode as D
import Bytes.Encode as E exposing (Encoder)
import Dict
import Json.Decode as Decode
import Json.Encode as Encode
import Logic.Component.Singleton as Singleton
import Logic.Launcher exposing (Error(..))
import Logic.Template.Component.SFX as AudioSprite exposing (AudioSprite)
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Internal.TexturesManager exposing (WorldDecoder)
import Logic.Template.SaveLoad.Internal.Util as Util


encode : Singleton.Spec AudioSprite world -> world -> Encoder
encode { get } world =
    let
        { config } =
            get world

        sprite =
            config.sprite
                |> Dict.toList
                |> E.list
                    (\( key, { offset, duration, loop } ) ->
                        E.sequence
                            [ E.sizedString key
                            , E.float offset
                            , E.float duration
                            , E.bool loop
                            ]
                    )

        src =
            config.src
                |> E.list E.sizedString
    in
    E.sequence [ src, sprite ]


decode : Singleton.Spec AudioSprite world -> WorldDecoder world
decode spec_ =
    let
        src =
            D.list D.sizedString

        sprite =
            D.list
                (D.map4
                    (\key offset duration loop ->
                        ( key
                        , { offset = offset
                          , duration = duration
                          , loop = loop
                          , cache = spriteCache key offset duration loop
                          }
                        )
                    )
                    D.sizedString
                    D.float
                    D.float
                    D.bool
                )
                |> D.map Dict.fromList
    in
    D.map2
        (\src_ sprite_ ->
            { src = [] -- no need - for runtime List.reverse src_
            , srcCache = Encode.list Encode.string (List.reverse src_)
            , sprite = sprite_
            }
        )
        src
        sprite
        |> D.map (\decoded -> Singleton.update spec_ (\a -> { a | config = decoded }))


read : Singleton.Spec AudioSprite world -> WorldReader world
read spec =
    { defaultRead
        | level =
            Async
                (\level ->
                    let
                        audiosprite =
                            level
                                |> Util.levelCommon
                                |> Util.properties
                                |> .file
                                |> (|>) "audiosprite"

                        spriteDecode =
                            Decode.map3
                                (\a b c ->
                                    { offset = a
                                    , duration = b
                                    , loop = c
                                    , cache = Encode.null
                                    }
                                )
                                (Decode.index 0 Decode.float)
                                (Decode.index 1 Decode.float)
                                (Decode.oneOf [ Decode.index 2 Decode.bool, Decode.succeed False ])
                    in
                    case audiosprite of
                        Just url ->
                            Loader.getJson url
                                >> ResourceTask.andThen
                                    (\value ->
                                        let
                                            empty =
                                                AudioSprite.empty

                                            config_ =
                                                value
                                                    |> Decode.decodeValue
                                                        (Decode.map3
                                                            (\src sprite srcCache -> { src = src, sprite = sprite, srcCache = srcCache })
                                                            (Decode.field "src" (Decode.list Decode.string))
                                                            (Decode.field "sprite" (Decode.dict spriteDecode))
                                                            (Decode.field "src" Decode.value)
                                                        )
                                        in
                                        case config_ of
                                            Ok config ->
                                                ResourceTask.succeed
                                                    (Tuple.mapSecond
                                                        (spec.set
                                                            ({ empty
                                                                | config = config
                                                             }
                                                                --                                                                |> AudioSprite.add { id = "Background" }
                                                                |> identity
                                                            )
                                                        )
                                                    )

                                            Err e ->
                                                ResourceTask.fail (Error 8001 (Decode.errorToString e))
                                    )

                        Nothing ->
                            ResourceTask.succeed identity
                )
    }


spriteCache key offset duration loop =
    Encode.object
        [ ( key
          , Encode.list identity
                [ Encode.float offset
                , Encode.float duration
                , Encode.bool loop
                ]
          )
        ]
