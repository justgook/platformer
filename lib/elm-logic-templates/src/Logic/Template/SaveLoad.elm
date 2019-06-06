module Logic.Template.SaveLoad exposing (loadBytes, loadFromBytes, loadTiled, loadTiledAndEncode)

import Bytes exposing (Bytes)
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E
import Logic.Launcher as Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.Decode as InternalD
import Logic.Template.SaveLoad.Internal.Encode
import Logic.Template.SaveLoad.Internal.Loader as Loader
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Reader)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (ResourceTask)
import Logic.Template.SaveLoad.Internal.TexturesManager as TexturesManager exposing (GetTexture)
import Logic.Template.SaveLoad.TiledReader as SaveLoad
import Task exposing (Task)


loadTiled : String -> world -> List (Reader world) -> Task Launcher.Error world
loadTiled levelUrl empty readers =
    loadTiledResourceTask levelUrl empty readers
        |> ResourceTask.toTask


loadTiledResourceTask : String -> world -> List (Reader world) -> ResourceTask world Loader.CacheTiled
loadTiledResourceTask levelUrl empty readers =
    ResourceTask.init
        |> Loader.getLevel levelUrl
        |> ResourceTask.andThen (SaveLoad.parse empty readers)


loadBytes : String -> world -> (GetTexture -> List (Decoder (world -> world))) -> ResourceTask world Loader.CacheBytes
loadBytes levelUrl world decoders =
    ResourceTask.init
        |> Loader.getBytes levelUrl
        |> ResourceTask.toTask
        |> Task.andThen (\bytes -> loadFromBytes bytes world decoders)


loadFromBytes : Bytes.Bytes -> world -> (GetTexture -> List (Decoder (world -> world))) -> ResourceTask world Loader.CacheBytes
loadFromBytes bytes world decoders =
    case D.decode TexturesManager.decoder bytes of
        Just decodeTextures ->
            ResourceTask.init
                |> TexturesManager.loadTask decodeTextures
                |> ResourceTask.andThen
                    (\loadedTextures ->
                        let
                            get =
                                TexturesManager.get loadedTextures

                            --                            _ =
                            --                                Debug.log "loadedTextures" loadedTextures
                            worldDecode =
                                bytes
                                    |> D.decode
                                        (TexturesManager.decoder
                                            |> D.andThen
                                                (\_ ->
                                                    decoders get
                                                        |> List.reverse
                                                        |> InternalD.sequence
                                                )
                                        )
                        in
                        Maybe.map (\f -> f world) worldDecode
                            |> Maybe.map ResourceTask.succeed
                            |> Maybe.withDefault (ResourceTask.fail (Error 1002 "Can not decode world"))
                    )

        Nothing ->
            Task.fail (Error 1001 "Can not decode textures")


loadTiledAndEncode url world read encoders lut =
    ResourceTask.init
        |> Loader.getLevel url
        |> ResourceTask.andThen
            (\level ->
                SaveLoad.parse world read level
                    >> ResourceTask.andThen
                        (\w ->
                            SaveLoad.parse TexturesManager.empty [ TexturesManager.read ] level
                                -->> ResourceTask.map (Debug.log "loadTiledAndEncode")
                                >> ResourceTask.map
                                    (\textures ->
                                        ( lut w textures, w )
                                    )
                        )
            )
        |> ResourceTask.map
            (\( textures, w ) ->
                let
                    encodedTextures =
                        TexturesManager.encoder textures

                    encodedWorld =
                        Logic.Template.SaveLoad.Internal.Encode.encoder encoders w

                    bytes =
                        E.encode <|
                            E.sequence
                                [ encodedTextures
                                , encodedWorld
                                ]
                in
                ( bytes, w )
            )
