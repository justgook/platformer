module Game.Update exposing (update)

-- |> Cmd.map Message.Texture

import Array
import Game.Message as Message exposing (Message)
import Game.Model exposing (Model)
import Game.TextureLoader as Texture
import QuadTree exposing (QuadTree)
import Util.BMP exposing (bmp24)
import Util.Level as Level


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        Message.Animate dt ->
            ( { model
                | runtime = dt + model.runtime
              }
            , Cmd.none
            )

        Message.LevelLoaded (Ok level) ->
            { model
                | level = level
                , collision = objectLayerParser level
            }
                ! [ textureLoader "http://localhost:8080/WIP/level1/" level ]

        Message.LevelLoaded (Err data) ->
            let
                _ =
                    Debug.log "Message.LoadMetadata ERROR" data
            in
            ( model, Cmd.none )

        Message.Texture m ->
            ( { model | textures = Texture.update m model.textures }, Cmd.none )


textureLoader : String -> { a | layers : List Level.Layer, tilesets : List Level.Tileset } -> Cmd Message
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


objectLayerParser : { a | layers : List Level.Layer } -> QuadTree (QuadTree.Bounded { data : { x : Float, y : Float, height : Float, width : Float } })
objectLayerParser level =
    -- Find Better name
    --MOVE TO Level.extra Decoder
    let
        filterObjectLayer a acc =
            case a of
                Level.ObjectLayer data ->
                    List.foldr getObjects acc data.objects

                _ ->
                    acc

        getObjects obj acc =
            case obj of
                (Level.ObjectRectangle { x, y, height, width }) as data ->
                    let
                        a =
                            { data = { x = x, y = y, height = height, width = width }
                            , boundingBox = QuadTree.boundingBox x (x + width) y (y + height)
                            }
                    in
                    { acc
                        | minX = min acc.minX x
                        , maxX = max acc.maxX x + width
                        , minY = min acc.minY y
                        , maxY = max acc.maxY y + height
                        , objecks = acc.objecks ++ [ a ]
                    }

                Level.ObjectEllipse { x, y, height, width } ->
                    let
                        a =
                            { data = { x = x, y = y, height = height, width = width }
                            , boundingBox = QuadTree.boundingBox x (x + width) y (y + height)
                            }
                    in
                    { acc
                        | minX = min acc.minX x
                        , maxX = max acc.maxX x + width
                        , minY = min acc.minY y
                        , maxY = max acc.maxY y + height
                        , objecks = acc.objecks ++ [ a ]
                    }

                _ ->
                    acc

        -- acc : { maxX : Float, maxY : Float, minX : Float, minY : Float, objecks : List { boundingBox : QuadTree.BoundingBox } }
        acc =
            { minX = 0.0, maxX = 0.0, minY = 0.0, maxY = 0.0, objecks = [] }

        result =
            List.foldl filterObjectLayer acc level.layers

        collision =
            QuadTree.emptyQuadTree (QuadTree.boundingBox result.minX result.maxX result.minY result.maxY) 5
                |> QuadTree.insertMany (Array.fromList result.objecks)
    in
    collision
