module World.Component.Util exposing (boolToFloat, extractObjectData, getTilesetByGid)

import Dict
import Error exposing (Error(..))
import ResourceTask
import Tiled.Tileset exposing (Tileset(..))
import Tiled.Util exposing (tilesetById)
import World.Component.Common exposing (GetTileset)


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0


getTilesetByGid : List Tileset -> GetTileset
getTilesetByGid tilesets gid =
    case tilesetById tilesets gid of
        Just (Tiled.Tileset.Source info) ->
            ResourceTask.getTileset info.source info.firstgid

        Just t ->
            ResourceTask.succeed t

        Nothing ->
            ResourceTask.fail (Error 5001 ("Not found Tileset for GID:" ++ String.fromInt gid))


extractObjectData gid t_ =
    case t_ of
        Embedded t ->
            Dict.get (gid - t.firstgid) t.tiles
                |> Maybe.andThen .objectgroup

        _ ->
            Nothing
