module Game.Update exposing (update)

-- |> Cmd.map Message.Texture
-- import Array
-- import QuadTree exposing (QuadTree)

import Game.Logic.Entity as Logic
import Game.Logic.Update as Logic
import Game.Message as Message exposing (Message)
import Game.Model as Model exposing (LoaderData(..), Model)
import Game.TextureLoader as Texture
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Set
import Util.BMP exposing (bmp24)
import Util.Level as Level


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case ( msg, model.renderData ) of
        ( Message.Logic msg, _ ) ->
            Logic.update msg model.world
                |> Tuple.mapFirst (\world -> { model | world = world })
                |> Tuple.mapSecond (Cmd.map Message.Logic)

        ( Message.LevelLoaded (Ok level), _ ) ->
            --TODO change Request to WebData
            { model
                | level = level
                , renderData = getRenderData level |> Loading
                , world = objectLayerParser level model.world
            }
                ! [ textureLoader "http://localhost:8080/WIP/level1/" level ]

        ( Message.LevelLoaded (Err data), _ ) ->
            let
                _ =
                    Debug.log "Message.LoadMetadata ERROR" data
            in
            ( model, Cmd.none )

        ( Message.Texture m, Loading data ) ->
            let
                textures =
                    Texture.update m model.textures
            in
            ( { model
                | textures = textures
                , renderData = validateResources textures data
              }
            , Cmd.none
            )

        ( Message.Texture m, _ ) ->
            let
                _ =
                    Debug.log "Texture Loaded after game start" m
            in
            ( model, Cmd.none )


validateResources : Texture.Model -> List Model.WaitingLayers -> LoaderData error (List Model.WaitingLayers) (List Model.RenderData)
validateResources textures renderData =
    if renderData == [] then
        Loading renderData
    else
        List.foldr
            (\layer ->
                case layer of
                    Model.WaitingActionLayer ->
                        Maybe.map
                            (\acc -> Model.ActionLayerRenderData :: acc)

                    Model.WaitingImageLayer { texture, x, y } ->
                        Maybe.map2
                            (\t acc -> Model.ImageLayerRenderData { texture = t, x = x, y = y } :: acc)
                            (Texture.get texture textures)

                    Model.WaitingTileLayer1 { lutTexture, tileSetTexture, lutSize, tileSetSize, transparentcolor, tileSize } ->
                        Maybe.map3
                            (\lutTexture tileSetTexture acc ->
                                Model.TileLayerRenderData
                                    { lutTexture = lutTexture
                                    , lutSize = lutSize
                                    , tileSetTexture = tileSetTexture
                                    , tileSetSize = tileSetSize
                                    , transparentcolor = transparentcolor
                                    , tileSize = tileSize
                                    }
                                    :: acc
                            )
                            (Texture.get lutTexture textures)
                            (Texture.get tileSetTexture textures)
            )
            (Just [])
            renderData
            |> Maybe.map Success
            |> Maybe.withDefault (Loading renderData)


getRenderData : Model.Level -> List Model.WaitingLayers
getRenderData level =
    --TODO merge with textureLoader and objectLayerParser
    let
        findTileSet id =
            List.foldl
                (\t acc ->
                    case t of
                        Level.TilesetEmbedded tileset ->
                            if id >= tileset.firstgid && id <= (tileset.firstgid + tileset.tilecount) then
                                -- { name = tileset.name
                                -- , tileSetSize = vec2 (toFloat tileset.imagewidth / toFloat tileset.tilewidth) (toFloat tileset.imageheight / toFloat tileset.tileheight)
                                -- , tileSize = vec2 (toFloat tileset.tilewidth) (toFloat tileset.tileheight)
                                -- , transparentcolor = hexColor2Vec3 tileset.transparentcolor |> Result.withDefault (vec3 0.0 0.0 0.0)
                                -- }
                                Just
                                    ( tileset.name
                                      -- tileSetSize
                                    , toFloat tileset.imagewidth / toFloat tileset.tilewidth
                                    , toFloat tileset.imageheight / toFloat tileset.tileheight
                                      -- tileSize
                                    , toFloat tileset.tilewidth
                                    , toFloat tileset.tileheight
                                      -- transparentcolor
                                    , tileset.transparentcolor
                                    )
                            else
                                acc

                        _ ->
                            acc
                )
                Nothing
                level.tilesets

        tileSetInfo =
            List.foldl
                (\t acc ->
                    findTileSet t
                        |> Maybe.map (flip Set.insert acc)
                        |> Maybe.withDefault acc
                )
                Set.empty
    in
    level.layers
        |> List.foldr
            (\layer acc ->
                case layer of
                    Level.ObjectLayer data ->
                        Model.WaitingActionLayer :: acc

                    --TODO merge it with textureLoader
                    Level.ImageLayer data ->
                        Model.WaitingImageLayer { x = data.x, y = data.y, texture = "Layer.Image::" ++ data.name } :: acc

                    Level.TileLayer data ->
                        case tileSetInfo data.data |> Set.toList of
                            ( name, tileSetSizeW, tileSetSizeH, tileSizeW, tileSizeH, transparentcolor ) :: [] ->
                                Model.WaitingTileLayer1
                                    { lutTexture = "Layer.Data::" ++ data.name
                                    , tileSetTexture = "Tiles::" ++ name
                                    , lutSize = vec2 (toFloat data.width) (toFloat data.height)
                                    , tileSetSize = vec2 tileSetSizeW tileSetSizeH
                                    , transparentcolor = hexColor2Vec3 transparentcolor |> Result.withDefault (vec3 0.0 0.0 0.0)
                                    , tileSize = vec2 tileSizeW tileSizeH
                                    }
                                    :: acc

                            data ->
                                let
                                    _ =
                                        Debug.log "Multiple tileset for one layer not yet supported" data
                                in
                                acc
            )
            []


textureLoader : String -> Model.Level -> Cmd Message
textureLoader prefix data =
    let
        tileImages t acc =
            case t of
                Level.TilesetEmbedded data ->
                    Texture.load ("Tiles::" ++ data.name) (prefix ++ data.image) :: acc

                Level.TilesetSource data ->
                    let
                        _ =
                            Debug.log "Implement Level.TilesetSource" data
                    in
                    acc

        loadDataAsImage data =
            bmp24 data.width data.height data.data
                |> Texture.load ("Layer.Data::" ++ data.name)

        layerImages l acc =
            case l of
                Level.ImageLayer data ->
                    Texture.load ("Layer.Image::" ++ data.name) (prefix ++ data.image) :: acc

                Level.TileLayer data ->
                    loadDataAsImage data :: acc

                Level.ObjectLayer data ->
                    acc
    in
    List.foldr tileImages [] data.tilesets
        ++ List.foldr layerImages [] data.layers
        |> Cmd.batch
        |> Cmd.map Message.Texture


objectLayerParser level world =
    let
        layers l acc =
            case l of
                Level.ImageLayer data ->
                    acc

                Level.TileLayer data ->
                    acc

                Level.ObjectLayer data ->
                    List.foldl objects acc data.objects

        objects o acc =
            case o of
                Level.ObjectRectangle data ->
                    case data.kind of
                        "Player" ->
                            Logic.spawnPlayer data acc

                        "Wall" ->
                            Logic.spawnWall data acc

                        "Collectable" ->
                            Logic.spawnCollectable data acc

                        _ ->
                            acc

                _ ->
                    acc
    in
    List.foldl layers world level.layers


hexColor2Vec3 : String -> Result String Vec3
hexColor2Vec3 str =
    let
        withoutHash =
            if String.startsWith "#" str then
                String.dropLeft 1 str
            else
                str
    in
    case String.toList withoutHash of
        [ r1, r2, g1, g2, b1, b2 ] ->
            let
                makeFloat a b =
                    String.fromList [ '0', 'x', a, b ]
                        |> String.toInt
                        |> Result.map (\i -> toFloat i / 255)
            in
            Result.map3 vec3 (makeFloat r1 r2) (makeFloat g1 g2) (makeFloat b1 b2)

        _ ->
            "Can not parse hex color:" ++ str |> Result.Err
