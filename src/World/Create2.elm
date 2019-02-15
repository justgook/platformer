module World.Create2 exposing (init)

import Array
import Defaults exposing (default)
import Dict
import Error exposing (Error(..))
import Layer
import Math.Vector2 exposing (Vec2, vec2)
import ResourceTask exposing (ResourceTask)
import Tiled exposing (gidInfo)
import Tiled.Layer
import Tiled.Tileset
import Tiled.Util exposing (common)
import WebGL.Texture
import World.Camera as Camera


delme =
    Layer.Object Array.empty


init level start =
    let
        --        tilesets =
        --            Tiled.Util.tilesets level
        --                |> Debug.log "aaa"
        --
        camera =
            Camera.init level

        --
        --        levelHeight =
        --            Tiled.Util.common level |> (\{ height, tileheight } -> tileheight * height |> toFloat)
        begin : ResourceTask ( List a, List Tiled.Tileset.Tileset )
        begin =
            ResourceTask.succeedWithCache ( [], Tiled.Util.tilesets level ) start

        layersTask =
            (common level).layers
                |> List.foldr
                    (\l ->
                        case l of
                            Tiled.Layer.Image imageData ->
                                --                                ( imageLayer imageData :: acc, tilesets )
                                ResourceTask.andThenWithCache
                                    (\( acc, tileset ) ->
                                        ResourceTask.succeedWithCache ( acc, tileset )
                                    )

                            _ ->
                                ResourceTask.andThenWithCache
                                    (\( acc, tileset ) ->
                                        ResourceTask.succeedWithCache ( acc, tileset )
                                    )
                     --                                ( ResourceTask.succeedWithCache delme)
                     --
                     --                            Tiled.Layer.Object objectData ->
                     --                                ( ResourceTask.succeedWithCache delme :: acc, tilesets )
                     --
                     --                            Tiled.Layer.Tile tileData ->
                     --                                ( tileLayer tilesets tileData :: acc, tilesets )
                     --
                     --                            Tiled.Layer.InfiniteTile tileChunkedData ->
                     --                                ( ResourceTask.succeedWithCache delme :: acc, tilesets )
                    )
                    begin
    in
    layersTask



--    ResourceTask.sequenceWithCache layers start


tileLayer tilesets { data } =
    let
        result =
            newSplitTileLayerByTileSet tilesets ( [], Dict.empty, Dict.empty ) data
    in
    result


newSplitTileLayerByTileSet tilesets ( cache, static, animated ) dataleft =
    case dataleft of
        gid :: rest ->
            let
                realGid =
                    (gidInfo gid).gid
            in
            if realGid == 0 then
                newSplitTileLayerByTileSet tilesets ( cache, static, animated ) rest

            else
                case tilesetById tilesets realGid of
                    Just (Tiled.Tileset.Embedded info) ->
                        newSplitTileLayerByTileSet tilesets ( cache, static, animated ) rest

                    Just ((Tiled.Tileset.Source { firstgid, source }) as was) ->
                        ResourceTask.getTileset ("/assets/" ++ source) firstgid
                            >> ResourceTask.andThenWithCache
                                (\tileset ->
                                    newSplitTileLayerByTileSet
                                        (updateTileset was tileset tilesets [])
                                        ( cache, static, animated )
                                        dataleft
                                )

                    Just (Tiled.Tileset.ImageCollection info) ->
                        let
                            _ =
                                Debug.log "got" "ImageCollection"
                        in
                        newSplitTileLayerByTileSet tilesets ( cache, static, animated ) rest

                    Nothing ->
                        ResourceTask.failWithCache (Error 5000 ("Not found Tileset for GID:" ++ String.fromInt gid))

        [] ->
            ResourceTask.succeedWithCache delme


updateTileset was now begin end =
    case begin of
        item :: left ->
            if item == was then
                left ++ (now :: end) |> List.reverse

            else
                updateTileset was now left (item :: end)

        [] ->
            end |> List.reverse


tilesetById : List Tiled.Tileset.Tileset -> Int -> Maybe Tiled.Tileset.Tileset
tilesetById tileset id =
    let
        innerfind predicate list =
            case list of
                first :: next :: rest ->
                    if predicate first (Just next) then
                        Just first

                    else
                        innerfind predicate (next :: rest)

                first :: rest ->
                    if predicate first Nothing then
                        Just first

                    else
                        innerfind predicate rest

                [] ->
                    Nothing
    in
    innerfind
        (\item next ->
            case ( item, next ) of
                ( Tiled.Tileset.Source info, Nothing ) ->
                    True

                ( Tiled.Tileset.Source info, Just nextTileset ) ->
                    id >= info.firstgid && id < firstGid nextTileset

                ( Tiled.Tileset.Embedded info, _ ) ->
                    id >= info.firstgid && id < info.firstgid + info.tilecount

                ( Tiled.Tileset.ImageCollection info, _ ) ->
                    id >= info.firstgid && id < info.firstgid + info.tilecount
        )
        tileset


firstGid : Tiled.Tileset.Tileset -> Int
firstGid item =
    case item of
        Tiled.Tileset.Source info ->
            info.firstgid

        Tiled.Tileset.Embedded info ->
            info.firstgid

        Tiled.Tileset.ImageCollection info ->
            info.firstgid


imageLayer imageData =
    let
        props =
            Tiled.Util.properties imageData
    in
    ResourceTask.getTexture ("/assets/" ++ imageData.image)
        >> ResourceTask.map
            (\t ->
                let
                    ( width, height ) =
                        WebGL.Texture.size t
                in
                Layer.Image
                    { image = t
                    , size = vec2 (toFloat width) (toFloat height)
                    , transparentcolor = props.color "transparentcolor" default.transparentcolor
                    , scrollRatio = scrollRatio (Dict.get "scrollRatio" imageData.properties == Nothing) props
                    }
            )


tileStaticLayerBuilder layerData =
    List.concatMap
        (\i ->
            case i of
                ( Tiled.Tileset.Embedded tileset, data ) ->
                    let
                        _ =
                            Debug.log "Tiled.Embedded" tileset.image
                    in
                    [{- always (ResourceTask.succeed (Tiled.Embedded tileset)) -}]

                ( Tiled.Tileset.Source { source, firstgid }, data ) ->
                    let
                        _ =
                            Debug.log "Tiled.Source" ("/assets/" ++ source)
                    in
                    [{- ResourceTask.getTileset ("/assets/" ++ source) firstgid -}]

                _ ->
                    []
        )


scrollRatio : Bool -> Tiled.Util.PropertiesReader -> Vec2
scrollRatio dual props =
    if dual then
        vec2 (props.float "scrollRatio.x" default.scrollRatio) (props.float "scrollRatio.y" default.scrollRatio)

    else
        vec2 (props.float "scrollRatio" default.scrollRatio) (props.float "scrollRatio" default.scrollRatio)
