module Game.PostDecoder.ObjectLayer exposing (parse)

import Dict exposing (Dict)
import Game.Logic.Camera.Model as Camera
import Game.Logic.Collision.Shape as Shape exposing (Shape(..))
import Game.Logic.Component as Component exposing (Component)
import Game.Model as Model exposing (LoaderData(..))
import Game.PostDecoder.Helpers exposing (findTileSet, hexColor2Vec3, scrollRatio, shapeById, findTileSetByName)
import Keyboard.Extra exposing (Direction(..), Key(ArrowDown, ArrowLeft, ArrowRight, ArrowUp))
import Math.Vector2 as Vec2 exposing (vec2, Vec2)
import Math.Vector3 exposing (vec3)
import Tiled.Decode as Tiled
import Image.BMP exposing (encode24)
import Util.KeysToDir exposing (arrows)
import Game.Logic.Direction as Direction


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


wrapCollsionData : Vec2 -> Shape -> Component.CollisionData
wrapCollsionData offset shape =
    { shapes = [ { shape = shape } ]
    , boundingBox = Shape.aabbData { shape = shape } |> Shape.createAABBData
    , response = vec2 0 0
    , offset = offset
    }


parse2 : List Tiled.Tileset -> Tiled.Object -> ( List (List (Component.Component String)), Dict String String ) -> ( List (List (Component.Component String)), Dict String String )
parse2 tilesets o ( acc, cmds ) =
    let
        position data =
            { p = Vec2.fromRecord { x = data.x, y = data.y } }
                |> Shape.Point
    in
        case o of
            Tiled.ObjectRectangle data ->
                ( [ Shape.createAABB
                        { p = vec2 data.x data.y
                        , xw = vec2 (data.width / 2) 0
                        , yw = vec2 0 (data.height / 2)
                        }
                        |> wrapCollsionData (vec2 0 0)
                        |> Component.Collision
                  ]
                    :: acc
                , cmds
                )

            Tiled.ObjectTile object ->
                --TODO remove that case
                case findTileSet object.gid tilesets of
                    Just ( _, tileset ) ->
                        let
                            ( comp, cmds_ ) =
                                parseAnimations object.gid object.properties tilesets

                            relative2absolute tileset_ { p, xw, yw } =
                                let
                                    x =
                                        object.x
                                            |> flip (-) (toFloat tileset_.tilewidth / 2)
                                            |> (+) (Vec2.getX xw)
                                            |> (+) (Vec2.getX p)

                                    y =
                                        object.y
                                            |> flip (+) (toFloat tileset_.tileheight / 2)
                                            |> flip (-) (Vec2.getY yw)
                                            |> flip (-) (Vec2.getY p)
                                in
                                    vec2 x y

                            shape =
                                findTileSet object.gid tilesets
                                    |> Maybe.andThen (\( _, tileset_ ) -> shapeById (relative2absolute tileset_) (object.gid - tileset_.firstgid) tileset_.tiles)
                                    |> Maybe.withDefault (position object)
                                    |> (\a ->
                                            let
                                                { p, xw, yw } =
                                                    Shape.aabbData { shape = a }

                                                offset =
                                                    p
                                                        |> Vec2.sub (vec2 object.x object.y)
                                            in
                                                wrapCollsionData offset a
                                       )
                                    |> Component.Collision

                            delme =
                                if object.kind == "Player" then
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
                                    , Component.Jump { impulse = 8.5, count = 1 }
                                    , Component.Camera (Camera.Follow { id = 0 })
                                    ]
                                else
                                    []
                        in
                            ( (comp ++ (shape :: delme)) :: acc
                            , Dict.fromList cmds_ |> Dict.union cmds
                            )

                    _ ->
                        ( acc, cmds )

            _ ->
                ( acc, cmds )


parseAnimations : Int -> Dict String Tiled.Property -> List Tiled.Tileset -> ( List (Component String), List ( String, String ) )
parseAnimations gid properties tilesets =
    let
        objectTilefirstgid =
            findTileSet gid tilesets
                |> Maybe.map Tuple.first
                |> Maybe.withDefault 0

        createOrUpdate direction newValue dict =
            Maybe.withDefault Dict.empty dict
                |> Dict.insert (Direction.fromString direction |> Direction.toInt) newValue
                |> Just

        addIdle prop =
            --TODO add other validations (E/Eeast/W/West)
            if Dict.get "Anim.idle.E.id" prop == Nothing then
                Dict.update "idle" (createOrUpdate "E" gid) prop
            else
                prop
    in
        Dict.foldr
            (\key value acc ->
                case ( value, String.split "." key ) of
                    ( Tiled.PropInt v, "Anim" :: name :: direction :: [ "id" ] ) ->
                        let
                            newFirstGid =
                                case Dict.get ("Anim." ++ name ++ "." ++ direction ++ ".tileset") properties of
                                    Just (Tiled.PropString gid_) ->
                                        findTileSetByName gid_ tilesets
                                            |> Maybe.map Tuple.first
                                            |> Maybe.withDefault 0

                                    _ ->
                                        objectTilefirstgid
                        in
                            Dict.update name (createOrUpdate direction (v + newFirstGid)) acc

                    _ ->
                        acc
            )
            Dict.empty
            properties
            |> addIdle
            |> fillAnimationData tilesets


fillAnimationData : List Tiled.Tileset -> Dict String (Dict Int Int) -> ( List (Component.Component String), List ( String, String ) )
fillAnimationData tilesets dict =
    let
        folder k v acc =
            let
                getAnimationData_ dir gid ( firstgid, tileset ) =
                    getAnimationData (k ++ toString dir) tileset (gid - firstgid)
            in
                case ( Dict.get (Direction.toInt Direction.East) v, Dict.get (Direction.toInt Direction.West) v ) of
                    ( Just east, Just west ) ->
                        let
                            _ =
                                Debug.log "TODO implement Game.PostDecoder.ObjectLayer::fillAnimationData"
                        in
                            acc

                    ( Just east, Nothing ) ->
                        findTileSet east tilesets
                            |> Maybe.andThen (getAnimationData_ (Direction.toInt Direction.East) east)
                            |> Maybe.map
                                (\( comp, cmds ) ->
                                    ( [ comp
                                      , { comp
                                            | name = (String.slice 0 -1 comp.name) ++ (Direction.toInt Direction.West |> toString)
                                            , mirror = ( True, False )
                                        }
                                      ]
                                    , cmds
                                    )
                                )
                            |> Maybe.map (\( comp, cmds ) -> Tuple.mapFirst ((++) comp) acc |> Tuple.mapSecond ((++) cmds))
                            |> Maybe.withDefault acc

                    ( Nothing, Just west ) ->
                        let
                            _ =
                                Debug.log "TODO implement Game.PostDecoder.ObjectLayer::fillAnimationData"
                        in
                            acc

                    _ ->
                        acc

        setDefaultAnimaion dict =
            let
                anim =
                    Dict.get "idle3" dict
                        |> (\a ->
                                if a == Nothing then
                                    Dict.values dict |> List.head
                                else
                                    a
                           )
                        |> Maybe.map (Component.Animation >> List.singleton)
                        |> Maybe.withDefault []
            in
                ( dict, anim )

        wrap =
            ((List.foldr
                (\a -> Dict.insert a.name a)
                Dict.empty
             )
                >> setDefaultAnimaion
                >> Tuple.mapFirst (Component.AnimationAtlas >> List.singleton)
                >> uncurry (++)
            )
    in
        Dict.foldl folder ( [], [] ) dict
            |> Tuple.mapFirst wrap


characterAnimation : Tiled.EmbeddedTileData -> Dict.Dict String Tiled.Property -> Component.AnimationData String -> ( List (Component.Component String), List ( String, String ) )
characterAnimation tileset properties stand =
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


getAnimationData : String -> Tiled.EmbeddedTileData -> Int -> Maybe ( Component.AnimationData String, List ( String, String ) )
getAnimationData animationName tileset tileId =
    Dict.get tileId tileset.tiles
        |> Maybe.andThen .animation
        |> Maybe.map (animationData animationName ((tileId + tileset.firstgid)) tileset)


animationData : String -> Int -> Tiled.EmbeddedTileData -> List { b | tileid : Int } -> ( Component.AnimationData String, List ( String, String ) )
animationData animationName gid tileset anims =
    ( { name = animationName
      , texture = tileset.image
      , lut = "Anim_LUT" ++ toString gid
      , frames = List.length anims
      , transparentcolor = hexColor2Vec3 tileset.transparentcolor |> Result.withDefault (vec3 1.0 0.0 1.0)
      , started = 0
      , width = toFloat tileset.tilewidth
      , height = toFloat tileset.tileheight
      , imageSize = vec2 (toFloat tileset.imagewidth) (toFloat tileset.imageheight)

      --   , frameSize = vec2 (toFloat tileset.tilewidth / toFloat tileset.imagewidth) (toFloat tileset.tileheight / toFloat tileset.imageheight)
      , columns = tileset.columns
      , mirror = ( False, False )
      }
    , [ ( tileset.image, tileset.image ), ( "Anim_LUT" ++ toString gid, encode24 (List.length anims) 1 (List.map .tileid anims) ) ]
    )
