module Game.PostDecoder exposing (DecodedData, decode)

import Dict
import Game.Logic.Collision.Map as Collision
import Game.Logic.World as World exposing (WorldProperties)
import Game.Model as Model exposing (LoaderData(..), Model)
import Game.PostDecoder.ImageLayer as ImageLayerParser
import Game.PostDecoder.ObjectLayer as ObjectLayerParser
import Game.PostDecoder.TileLayer as TileLayerParser
import Json.Decode
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Tiled.Decode as Tiled


type alias DecodedData =
    { layersData : List (Model.Data String)
    , commands : List ( String, String )
    , properties : WorldProperties
    , collisionMap : World.CollisionMap
    }


decode : String -> Json.Decode.Decoder DecodedData
decode urlPrefix =
    Tiled.decode
        |> Json.Decode.andThen
            (\level ->
                let
                    levelHeight =
                        toFloat (level.height * level.tileheight)

                    tilesets =
                        level.tilesets
                            |> List.map
                                (\tileset ->
                                    case tileset of
                                        Tiled.TilesetEmbedded data ->
                                            Tiled.TilesetEmbedded { data | image = urlPrefix ++ data.image }

                                        _ ->
                                            tileset
                                )

                    layers =
                        level.layers
                            |> List.map
                                (\layer ->
                                    case layer of
                                        Tiled.ImageLayer data ->
                                            Tiled.ImageLayer { data | image = urlPrefix ++ data.image }

                                        Tiled.ObjectLayer layerData ->
                                            { layerData
                                                | objects =
                                                    List.map
                                                        (\object ->
                                                            case object of
                                                                -- TODO UPDATE to center points
                                                                -- Inverting postion of all objects in Layer
                                                                -- (from topLeft to bottomLeft, and setting position to center)
                                                                Tiled.ObjectRectangle data ->
                                                                    Tiled.ObjectRectangle
                                                                        { data
                                                                            | y = levelHeight - data.y - (data.height / 2)
                                                                            , x = data.x + (data.width / 2)
                                                                        }

                                                                Tiled.ObjectPoint data ->
                                                                    Tiled.ObjectPoint { data | y = levelHeight - data.y }

                                                                Tiled.ObjectPolygon data ->
                                                                    object

                                                                Tiled.ObjectPolyLine data ->
                                                                    object

                                                                Tiled.ObjectEllipse data ->
                                                                    Tiled.ObjectEllipse
                                                                        { data
                                                                            | y = levelHeight - data.y - (data.height / 2)
                                                                            , x = data.x + (data.width / 2)
                                                                        }

                                                                Tiled.ObjectTile data ->
                                                                    -- (- data.height) === https://github.com/bjorn/tiled/issues/91
                                                                    Tiled.ObjectTile
                                                                        { data
                                                                            | y = levelHeight - data.y + (data.height / 2)
                                                                            , x = data.x + (data.width / 2)
                                                                        }
                                                        )
                                                        layerData.objects
                                            }
                                                |> Tiled.ObjectLayer

                                        _ ->
                                            layer
                                )
                in
                    Json.Decode.succeed
                        (prepareRenderData
                            { level
                                | tilesets = tilesets
                                , layers = layers
                            }
                        )
            )


prepareRenderData : Tiled.Level -> DecodedData
prepareRenderData level =
    let
        ( layersData, collisionMap, commands ) =
            level.layers
                |> List.foldr
                    (\layer ( acc, collisionMap, cmds ) ->
                        case layer of
                            Tiled.ObjectLayer data ->
                                let
                                    ( reslt, images ) =
                                        ObjectLayerParser.parse data level.tilesets
                                in
                                    ( reslt :: acc, collisionMap, Dict.union cmds images )

                            Tiled.ImageLayer data ->
                                let
                                    ( reslt, images ) =
                                        ImageLayerParser.parse data
                                in
                                    ( reslt :: acc, collisionMap, Dict.union cmds images )

                            Tiled.TileLayer data ->
                                case TileLayerParser.parse level collisionMap data of
                                    Ok ( reslt, updatedCollisionMap, images ) ->
                                        ( reslt :: acc, updatedCollisionMap, Dict.union cmds images )

                                    Err err ->
                                        Debug.log err
                                            ( acc, collisionMap, cmds )
                    )
                    ( [], Collision.empty ( level.tilewidth, level.tileheight ), Dict.empty )
    in
        { layersData = layersData
        , commands = Dict.toList commands
        , properties = parseWorldProperties level.properties
        , collisionMap = collisionMap
        }


parseWorldProperties : Tiled.CustomProperties -> WorldProperties
parseWorldProperties props =
    { gravity = vec2 0 (getFloatProp "gravity" 1 props)
    , pixelsPerUnit = getFloatProp "pixelsPerUnit" 120 props
    }


getFloatProp : String -> Float -> Dict.Dict String Tiled.Property -> Float
getFloatProp propName default dict =
    Dict.get propName dict
        |> Maybe.andThen
            (\prop ->
                case prop of
                    Tiled.PropFloat a ->
                        Just a

                    _ ->
                        Nothing
            )
        |> Maybe.withDefault default
