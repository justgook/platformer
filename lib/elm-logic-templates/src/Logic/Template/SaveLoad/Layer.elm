module Logic.Template.SaveLoad.Layer exposing (decode, encode, lutCollector, objLayerRead, read, updateObjLayer)

import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder)
import Bytes.Encode as E exposing (Encoder)
import Logic.Component
import Logic.Component.Singleton as Singleton
import Logic.Entity as Entity
import Logic.Template.Component.Layer exposing (Layer)
import Logic.Template.SaveLoad.ImageLayer as ImageLayer
import Logic.Template.SaveLoad.Internal.Decode as D
import Logic.Template.SaveLoad.Internal.Encode as E
import Logic.Template.SaveLoad.Internal.Reader as Reader exposing (Read(..), WorldReader, defaultRead)
import Logic.Template.SaveLoad.Internal.TexturesManager as TexturesManager exposing (DecoderWithTexture, Manager, Selector(..))
import Logic.Template.SaveLoad.Internal.Util as Util
import Logic.Template.SaveLoad.TileLayer as TileLayer exposing (TileLayer(..))
import Math.Vector2 as Vec2
import Math.Vector3 as Vec3



--lutCollector : { a | layers : List Layer } -> Manager PixelData -> Manager PixelData


lutCollector : { a | layers : List Layer } -> Manager Bytes -> Manager Bytes
lutCollector { layers } t =
    --TODO remove when there will be sync texture creation from bytes
    layers
        |> List.foldl
            (\layar acc ->
                case layar of
                    Logic.Template.Component.Layer.Tiles { id, data, uLutSize } ->
                        let
                            { x, y } =
                                Vec2.toRecord uLutSize

                            w =
                                round x

                            h =
                                round y

                            lut2 =
                                Util.imageBytes w data
                        in
                        TexturesManager.setLut id w h lut2 acc

                    _ ->
                        acc
            )
            t


read : Singleton.Spec (List Layer) world -> WorldReader world
read spec =
    let
        imageLayerSpec =
            { get = \_ -> []
            , set = \c -> Singleton.update spec (\layers -> layers ++ List.map wrapImageLayer c)
            }

        tileLayerSpec =
            { get = \_ -> []
            , set = \c -> Singleton.update spec (\layers -> layers ++ List.map wrapTileLayer c)
            }

        objLayerSpec id =
            { get = \w -> findObjLayer id (spec.get w)
            , set = \c -> Singleton.update spec (\layers -> updateObjLayer id (Logic.Template.Component.Layer.Object ( id, c )) [] layers)
            }
    in
    TileLayer.read tileLayerSpec
        |> Reader.combine (ImageLayer.read imageLayerSpec)
        |> Reader.combine (objLayerRead objLayerSpec)


encode : Singleton.Spec (List Layer) world -> world -> Encoder
encode { get } world =
    let
        imageData layerType info =
            E.sequence
                [ E.unsignedInt8 layerType
                , E.id info.id
                , E.xyz (Vec3.toRecord info.uTransparentColor)
                , E.xy (Vec2.toRecord info.scrollRatio)
                , E.xy (Vec2.toRecord info.uSize)
                ]

        tilesData layerType info =
            E.sequence
                [ E.unsignedInt8 layerType
                , E.id info.id
                , E.id info.firstgid
                , E.xy (Vec2.toRecord info.uLutSize)
                , E.xy (Vec2.toRecord info.uAtlasSize)
                , E.xy (Vec2.toRecord info.uTileSize)
                , E.xyz (Vec3.toRecord info.uTransparentColor)
                , E.xy (Vec2.toRecord info.scrollRatio)
                ]
    in
    get world
        |> E.list
            (\layer ->
                case layer of
                    Logic.Template.Component.Layer.Object ( _, info ) ->
                        let
                            objectLayer =
                                Entity.toList info
                                    |> E.list
                                        (\( i, _ ) -> E.unsignedInt32 BE i)
                        in
                        E.sequence [ E.unsignedInt8 0, objectLayer ]

                    Logic.Template.Component.Layer.ImageNo info ->
                        imageData 1 info

                    Logic.Template.Component.Layer.ImageX info ->
                        imageData 2 info

                    Logic.Template.Component.Layer.ImageY info ->
                        imageData 3 info

                    Logic.Template.Component.Layer.Image info ->
                        imageData 4 info

                    Logic.Template.Component.Layer.Tiles info ->
                        tilesData 5 info

                    Logic.Template.Component.Layer.AnimatedTiles _ ->
                        E.unsignedInt8 6
            )


decode : Singleton.Spec (List Layer) world -> DecoderWithTexture world
decode spec_ getTexture =
    let
        imageData =
            D.map4
                (\id uTransparentColor scrollRatio uSize ->
                    case getTexture Image id of
                        Just image ->
                            D.succeed
                                { id = id
                                , uSize = Vec2.fromRecord uSize
                                , uTransparentColor = Vec3.fromRecord uTransparentColor
                                , scrollRatio = Vec2.fromRecord scrollRatio
                                , image = image
                                }

                        Nothing ->
                            D.fail
                )
                D.id
                D.xyz
                D.xy
                D.xy
                |> D.andThen identity

        tiledData =
            D.succeed
                (\id firstgid uLutSize uAtlasSize uTileSize uTransparentColor scrollRatio ->
                    Maybe.map2
                        (\uAtlas uLut ->
                            D.succeed
                                { uAtlasSize = uAtlasSize |> Vec2.fromRecord
                                , uAtlas = uAtlas
                                , uTileSize = uTileSize |> Vec2.fromRecord
                                , uTransparentColor = uTransparentColor |> Vec3.fromRecord
                                , scrollRatio = scrollRatio |> Vec2.fromRecord
                                , uLutSize = uLutSize |> Vec2.fromRecord
                                , uLut = uLut

                                -- Encoding related
                                , firstgid = 0
                                , id = 0
                                , data = []
                                }
                        )
                        (getTexture Atlas firstgid)
                        (getTexture Lut id)
                        |> Maybe.withDefault D.fail
                )
                |> D.andMap D.id
                |> D.andMap D.id
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.xy
                |> D.andMap D.xyz
                |> D.andMap D.xy
                |> D.andThen identity

        decoder =
            D.unsignedInt8
                |> D.andThen
                    (\layerType ->
                        case layerType of
                            0 ->
                                D.reverseList (D.map (\i -> ( i, () )) D.id)
                                    |> D.map (\l -> Logic.Template.Component.Layer.Object ( 0, Entity.fromList l ))

                            1 ->
                                D.map Logic.Template.Component.Layer.ImageNo imageData

                            2 ->
                                D.map Logic.Template.Component.Layer.ImageX imageData

                            3 ->
                                D.map Logic.Template.Component.Layer.ImageY imageData

                            4 ->
                                D.map Logic.Template.Component.Layer.Image imageData

                            5 ->
                                D.map Logic.Template.Component.Layer.Tiles tiledData

                            6 ->
                                D.fail

                            _ ->
                                D.fail
                    )
    in
    D.reverseList decoder
        |> D.map
            (\list -> Singleton.update spec_ ((++) (List.reverse list)))



--


objLayerRead : (Int -> Logic.Component.Spec () world) -> WorldReader world
objLayerRead spec =
    { defaultRead
        | objectTile = Sync (\{ layer } -> Entity.with ( spec layer.id, () ))
        , objectPoint = Sync (\{ layer } -> Entity.with ( spec layer.id, () ))
        , objectRectangle = Sync (\{ layer } -> Entity.with ( spec layer.id, () ))
        , objectEllipse = Sync (\{ layer } -> Entity.with ( spec layer.id, () ))
        , objectPolygon = Sync (\{ layer } -> Entity.with ( spec layer.id, () ))
        , objectPolyLine = Sync (\{ layer } -> Entity.with ( spec layer.id, () ))
    }


wrapTileLayer : TileLayer.TileLayer -> Logic.Template.Component.Layer.Layer
wrapTileLayer layer =
    case layer of
        TileLayer.Tiles info ->
            Logic.Template.Component.Layer.Tiles info

        TileLayer.AnimatedTiles info ->
            Logic.Template.Component.Layer.AnimatedTiles info


wrapImageLayer : ImageLayer.ImageLayer -> Logic.Template.Component.Layer.Layer
wrapImageLayer { id, repeat, image, uSize, uTransparentColor, scrollRatio } =
    { image = image
    , uSize = uSize
    , uTransparentColor = uTransparentColor
    , scrollRatio = scrollRatio
    , id = id
    }
        |> (case repeat of
                ImageLayer.RepeatX ->
                    Logic.Template.Component.Layer.ImageX

                ImageLayer.RepeatY ->
                    Logic.Template.Component.Layer.ImageY

                ImageLayer.RepeatNo ->
                    Logic.Template.Component.Layer.ImageNo

                ImageLayer.Repeat ->
                    Logic.Template.Component.Layer.Image
           )


updateObjLayer id value next prev =
    case prev of
        [] ->
            List.reverse (prev ++ value :: next)

        first :: rest ->
            case first of
                Logic.Template.Component.Layer.Object ( checkMe, _ ) ->
                    if checkMe == id then
                        List.reverse (value :: next) ++ rest

                    else
                        updateObjLayer id value (first :: next) rest

                _ ->
                    updateObjLayer id value (first :: next) rest


findObjLayer : Int -> List Layer -> Logic.Component.Set ()
findObjLayer id list =
    case list of
        [] ->
            Logic.Component.empty

        first :: rest ->
            case first of
                Logic.Template.Component.Layer.Object ( checkMe, objLayerComponents ) ->
                    if checkMe == id then
                        objLayerComponents

                    else
                        findObjLayer id rest

                _ ->
                    findObjLayer id rest
