module Develop exposing (init)

import Browser.Dom as Browser
import Common exposing (OwnWorld, decoders, emptyWorld, encoders, read)
import Json.Decode as Decode exposing (Value)
import Logic.Template.RenderInfo as RenderInfo exposing (RenderInfo)
import Logic.Template.SaveLoad as SaveLoad
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask
import Logic.Template.SaveLoad.Layer exposing (lutCollector)
import Task


init flags =
    let
        levelUrl =
            flags
                |> Decode.decodeValue (Decode.field "levelUrl" Decode.string)
                |> Result.withDefault "default.json"

        world =
            flags
                |> Decode.decodeValue (Decode.field "world" Decode.string)
                |> Debug.log "world???"
    in
    SaveLoad.loadTiledAndEncode levelUrl emptyWorld read encoders lutCollector
        |> ResourceTask.toTask
        |> Task.andThen
            (\( bytesOfWorld, worldFromTiled ) ->
                SaveLoad.loadBytes bytesOfWorld emptyWorld decoders
                    |> ResourceTask.map
                        (\wFromBytes_ ->
                            let
                                _ =
                                    Debug.log "bytesOfWorld" bytesOfWorld

                                wFromBytes =
                                    { wFromBytes_
                                        | physics = worldFromTiled.physics
                                    }
                            in
                            wFromBytes
                        )
                    |> ResourceTask.toTask
            )
        --    SaveLoad.loadTiled levelUrl emptyWorld read
        |> Task.map2
            (\{ scene } w ->
                RenderInfo.resize RenderInfo.spec w (round scene.width) (round scene.height)
            )
            Browser.getViewport
