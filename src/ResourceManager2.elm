module ResourceManager2 exposing (Message, Model, init)

import Http
import Json.Decode as Json
import Resource
import Task
import Tiled
import Tiled.Level
import Tiled.Tileset
import Tiled.Util
import WebGL.Texture


type alias Model msg =
    Resource.Model ResourceStorage msg


type ResourceStorage
    = Image WebGL.Texture.Texture
    | Tileset Tiled.Tileset.Tileset
    | Level Tiled.Level.Level


type alias Message =
    Resource.Resource (Result Http.Error ResourceStorage)


init msg =
    let
        resource =
            Resource.init msg
    in
    resource
        |> getJson "/assets/debug2.json" (Tiled.decode |> Json.map Level)
        |> Resource.when "/assets/debug2.json" downloadAllTilesets


getJson url decoder =
    Resource.task url (Resource.getJson url decoder)


getImage url =
    Resource.task url
        (WebGL.Texture.load url
            |> Task.map Image
            |> Task.mapError (\_ -> Http.BadBody "TextureProblms")
        )


downloadAllImagesFromTilesets res acc =
    case res of
        Tileset (Tiled.Tileset.Embedded t) ->
            acc |> getImage ("/assets/" ++ t.image)

        _ ->
            acc


downloadAllTilesets res acc =
    case res of
        Level l ->
            l
                |> Tiled.Util.tilesets
                |> List.foldl
                    (\tilest acc_ ->
                        case tilest of
                            Tiled.Tileset.Source { source, firstgid } ->
                                acc_
                                    |> getJson ("/assets/" ++ source) (Tiled.Tileset.decodeFile firstgid |> Json.map Tileset)
                                    |> Resource.when ("/assets/" ++ source) downloadAllImagesFromTilesets

                            _ ->
                                acc_
                    )
                    acc

        _ ->
            acc
