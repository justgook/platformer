module Game.PostDecoder.ObjectLayer exposing (parse)

import Dict exposing (Dict)
import Game.Logic.Camera.Model as Camera
import Game.Logic.Collision.Shape as Shape exposing (AabbData, Shape(..))
import Game.Logic.Component as Component
import Game.Model as Model exposing (LoaderData(..), Model)
import Game.PostDecoder.Helpers exposing (findTileSet, getFloatProp, hexColor2Vec3, scrollRatio, shapeById, tileSetInfo)
import Keyboard.Extra exposing (Direction(..), Key(ArrowDown, ArrowLeft, ArrowRight, ArrowUp))
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Tiled.Decode as Tiled
import Util.BMP exposing (bmp24)
import Util.KeysToDir exposing (arrows)


parse : Tiled.ObjectLayerData -> List Tiled.Tileset -> ( Model.Data String, Dict String String )
parse data tilesets =
    -- , properties : CustomProperties
    List.foldr (parse2 tilesets) ( [], Dict.empty ) data.objects
        |> Tuple.mapFirst
            (\ents ->
                Model.ActionLayer
                    { components = ents
                    , scrollRatio = scrollRatio data
                    }
            )


wrapCollsionData : Shape -> Component.CollisionData
wrapCollsionData shape =
    { shape = shape, response = vec2 0 0 }


parse2 : List Tiled.Tileset -> Tiled.Object -> ( List (List (Component.Component String)), Dict String String ) -> ( List (List (Component.Component String)), Dict String String )
parse2 tilesets o ( acc, cmds ) =
    let
        position data =
            { p = Vec2.fromRecord { x = data.x, y = data.y } }
                |> Shape.Point
    in
        case o of
            Tiled.ObjectRectangle data ->
                -- case data.kind of
                --     "Player" ->
                --         ( acc, cmds )
                --     "Collectable" ->
                --         ( acc, cmds )
                --     _ ->
                ( [ Shape.createAABB
                        { p = vec2 data.x data.y
                        , xw = vec2 (data.width / 2) 0
                        , yw = vec2 0 (data.height / 2)
                        }
                        |> wrapCollsionData
                        |> Component.Collision
                  ]
                    :: acc
                , cmds
                )

            Tiled.ObjectTile data ->
                case findTileSet data.gid tilesets of
                    Just ( _, tileset ) ->
                        let
                            ( comp, cmds_ ) =
                                getAnimationData tileset (data.gid - tileset.firstgid)
                                    |> Maybe.map
                                        (\( a, b ) ->
                                            characterAnimation tileset data.properties a
                                                |> Tuple.mapSecond ((++) b)
                                        )
                                    |> Maybe.withDefault (sprite tileset)

                            relative2absolute =
                                Vec2.scale 0.5 >> Vec2.sub (vec2 data.x data.y)

                            shape =
                                shapeById relative2absolute (data.gid - tileset.firstgid) tileset.tiles
                                    |> Maybe.withDefault (position data)
                                    |> wrapCollsionData
                                    |> Component.Collision

                            delme =
                                --  "buttonLeft",
                                if data.kind == "Player" then
                                    [ Component.Input
                                        { x = 0
                                        , y = 0
                                        , parse =
                                            arrows
                                                { left = ArrowLeft
                                                , up = ArrowUp
                                                , right = ArrowRight
                                                , down = ArrowDown
                                                }
                                        }
                                    , Component.Velocity (vec2 0 0)
                                    , Component.Camera (Camera.Follow { id = 0 })
                                    ]
                                else
                                    []
                        in
                            ( (comp ++ [ shape ] ++ delme) :: acc
                            , Dict.fromList cmds_ |> Dict.union cmds
                            )

                    _ ->
                        ( acc, cmds )

            _ ->
                ( acc, cmds )


characterAnimation : Tiled.EmbeddedTileData -> Dict String Tiled.Property -> Component.AnimationData String -> ( List (Component.Component String), List ( String, String ) )
characterAnimation tileset properties stand =
    let
        addLeft a =
            { right = a
            , left = { a | mirror = ( True, False ) }
            , stand = stand
            }

        addRight a =
            { left = a
            , right = { a | mirror = ( True, False ) }
            , stand = stand
            }

        resultWrapper add =
            (add >> Component.CharacterAnimation >> flip (::) [ Component.Animation stand ])
                |> Tuple.mapFirst
                |> Maybe.map
    in
        case ( Dict.get "runLeftAnim" properties, Dict.get "runRightAnim" properties ) of
            ( Just (Tiled.PropInt runLeftAnim), Just (Tiled.PropInt runRightAnim) ) ->
                Maybe.map2
                    (\( l, a ) ( r, b ) ->
                        ( [ Component.Animation stand
                          , Component.CharacterAnimation
                                { left = l
                                , right = r
                                , stand = stand
                                }
                          ]
                        , a ++ b
                        )
                    )
                    (getAnimationData tileset runLeftAnim)
                    (getAnimationData tileset runRightAnim)
                    |> Maybe.withDefault ( [ Component.Animation stand ], [] )

            ( Just (Tiled.PropInt runLeftAnim), Nothing ) ->
                getAnimationData tileset runLeftAnim
                    |> resultWrapper addRight
                    |> Maybe.withDefault ( [ Component.Animation stand ], [] )

            ( Nothing, Just (Tiled.PropInt runRightAnim) ) ->
                getAnimationData tileset runRightAnim
                    |> resultWrapper addLeft
                    |> Maybe.withDefault ( [ Component.Animation stand ], [] )

            _ ->
                ( [ Component.Animation stand ], [] )


sprite : Tiled.EmbeddedTileData -> ( List (Component.Component String), List ( String, String ) )
sprite data =
    ( [ Component.Sprite
            { texture = data.image
            , transparentcolor = hexColor2Vec3 data.transparentcolor |> Result.withDefault (vec3 1.0 0.0 1.0)
            }
      ]
    , [ ( data.image, data.image ) ]
    )


getAnimationData : Tiled.EmbeddedTileData -> Int -> Maybe ( Component.AnimationData String, List ( String, String ) )
getAnimationData tileset tileId =
    let
        animationData gid tileset anims =
            ( { texture = tileset.image
              , lut = "Anim_LUT" ++ gid
              , frames = List.length anims |> toFloat
              , transparentcolor = hexColor2Vec3 tileset.transparentcolor |> Result.withDefault (vec3 1.0 0.0 1.0)
              , started = 0
              , width = toFloat tileset.tilewidth
              , height = toFloat tileset.tileheight
              , frameSize = vec2 (toFloat tileset.tilewidth / toFloat tileset.imagewidth) (toFloat tileset.tileheight / toFloat tileset.imageheight)
              , columns = toFloat tileset.columns
              , mirror = ( False, False )
              }
            , [ ( tileset.image, tileset.image ), ( "Anim_LUT" ++ gid, bmp24 (List.length anims) 1 (List.map .tileid anims) ) ]
            )
    in
        Dict.get tileId tileset.tiles
            |> Maybe.andThen .animation
            |> Maybe.map (animationData (toString (tileId + tileset.firstgid)) tileset)
