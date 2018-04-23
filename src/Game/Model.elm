module Game.Model
    exposing
        ( Data(..)
        , LoaderData(..)
        , Model
        , Repeat(..)
        , init
        , loadingToSuccess
        , updateCameraWidthRatio
        , updateWidthRatio
        )

-- import RemoteData exposing (WebData)
-- import Util.Level.Special as Level exposing (LevelProps, SpecialLayer)
-- import Tiled.Decode exposing (Layer, LevelWith, Tileset)
-- import Game.Logic.Collision.Map exposing (Map)

import Game.Logic.Camera.Model as Camera
import Game.Logic.Component as Component exposing (Component)
import Game.Logic.World as World exposing (World, WorldProperties)
import Game.TextureLoader as TextureLoader
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Slime exposing ((&=>))
import WebGL


type alias Model =
    { widthRatio : Float
    , renderData : RenderData
    }


type alias RenderData =
    LoaderData String
        WhileLoading
        { data : List (Data WebGL.Texture)
        , world : World
        , checkPoint : World
        }


init : Model
init =
    { widthRatio = 1
    , renderData = NotAsked
    }


updateWidthRatio : { a | height : Int, width : Int } -> Model -> Model
updateWidthRatio size model =
    let
        widthRatio =
            toFloat size.width / toFloat size.height

        renderData =
            updateCameraWidthRatio widthRatio model.renderData
    in
    { model | widthRatio = widthRatio, renderData = renderData }


updateCameraWidthRatio : Float -> RenderData -> RenderData
updateCameraWidthRatio widthRatio renderData =
    case renderData of
        Success data ->
            let
                world =
                    data.world
            in
            Success
                { data
                    | world =
                        { world
                            | camera = Camera.setWidthRatio widthRatio world.camera
                        }
                }

        _ ->
            renderData


type LoaderData error loadingData resultData
    = NotAsked
    | Loading loadingData
    | Failure error
    | Success resultData


type alias WhileLoading =
    { data : List (Data String)
    , properties : WorldProperties
    , textures : TextureLoader.Model
    , collisionMap : World.CollisionMap
    }


type Data image
    = ImageLayer (ImageLayerData image)
    | TileLayer1 (TileLayer1Data image)
    | ActionLayer
        { components : List (List (Component image))
        , scrollRatio : Vec2
        }


type alias ImageLayerData image =
    { texture : image
    , x : Float
    , y : Float
    , transparentcolor : Vec3
    , scrollRatio : Vec2
    , repeat : Repeat
    }


type alias TileLayer1Data image =
    { lutTexture : image
    , lutSize : Vec2
    , firstgid : Int
    , tileSetTexture : image
    , tileSetSize : Vec2
    , transparentcolor : Vec3
    , tileSize : Vec2
    , scrollRatio : Vec2
    , repeat : Repeat
    }


type Repeat
    = RepeatBoth
    | RepeatNone
    | RepeatX
    | RepeatY


loadingToSuccess : WhileLoading -> RenderData
loadingToSuccess ({ textures, properties, collisionMap } as income) =
    if income.data == [] then
        Loading income
    else
        List.foldr
            (\layer ->
                case layer of
                    ActionLayer actionLayer ->
                        let
                            entities =
                                actionLayer.components

                            func comp result =
                                result

                            result =
                                entities
                                    |> componentTransform
                                        (\comp ->
                                            let
                                                animationData data texture lut =
                                                    Maybe.map2 (\t l -> { data | texture = t, lut = l })
                                                        (TextureLoader.get texture textures)
                                                        (TextureLoader.get lut textures)
                                            in
                                            case comp of
                                                Component.Animation ({ texture, lut } as data) ->
                                                    animationData data texture lut
                                                        |> Maybe.map Component.Animation

                                                -- `andMap = map2 (|>)` and do
                                                -- ```Maybe.map yourFunction maybe1
                                                --   |> andMap maybe2
                                                --   |> andMap maybe3
                                                --   [..]
                                                --   |> andMap maybe6```
                                                Component.CharacterAnimation data ->
                                                    Maybe.map3
                                                        (\l r s -> { left = l, right = r, stand = s })
                                                        (animationData data.left data.left.texture data.left.lut)
                                                        (animationData data.right data.right.texture data.right.lut)
                                                        (animationData data.stand data.stand.texture data.stand.lut)
                                                        |> Maybe.map Component.CharacterAnimation

                                                Component.Sprite ({ texture } as data) ->
                                                    Maybe.map
                                                        (\t -> Component.Sprite { data | texture = t })
                                                        (TextureLoader.get texture textures)

                                                Component.Collision data ->
                                                    Just (Component.Collision data)

                                                Component.Velocity data ->
                                                    Just (Component.Velocity data)

                                                Component.Input data ->
                                                    Just (Component.Input data)

                                                Component.Camera data ->
                                                    Just (Component.Camera data)
                                        )
                        in
                        Maybe.map2
                            (\ents acc -> ActionLayer { actionLayer | components = ents } :: acc)
                            result

                    ImageLayer ({ texture } as data) ->
                        Maybe.map2
                            (\image acc ->
                                ImageLayer { data | texture = image } :: acc
                            )
                            (TextureLoader.get texture textures)

                    TileLayer1 ({ lutTexture, tileSetTexture } as data) ->
                        Maybe.map3
                            (\lutTexture tileSetTexture acc ->
                                TileLayer1 { data | lutTexture = lutTexture, tileSetTexture = tileSetTexture } :: acc
                            )
                            (TextureLoader.get lutTexture textures)
                            (TextureLoader.get tileSetTexture textures)
            )
            (Just [])
            income.data
            |> Maybe.map
                (\data ->
                    let
                        world =
                            createWorld data properties collisionMap
                    in
                    Success
                        { data = data
                        , world = world
                        , checkPoint = world
                        }
                )
            |> Maybe.withDefault (Loading income)


createWorld : List (Data WebGL.Texture) -> WorldProperties -> World.CollisionMap -> World
createWorld layers props collisionMap =
    List.foldr spawn (World.init props collisionMap) layers


spawn : Data WebGL.Texture -> World -> World
spawn layer world =
    case layer of
        ActionLayer { components } ->
            List.foldl spawnOne world components

        _ ->
            world


spawnOne : List (Component WebGL.Texture) -> World -> World
spawnOne entity world =
    let
        ( entityId, newWorld ) =
            List.foldl
                (\comp acc ->
                    case comp of
                        Component.Animation data ->
                            acc &=> ( World.animations, data )

                        Component.CharacterAnimation data ->
                            acc &=> ( World.characterAnimations, data )

                        Component.Sprite data ->
                            acc &=> ( World.sprites, data )

                        Component.Collision data ->
                            acc &=> ( World.collisions, data )

                        Component.Input data ->
                            acc &=> ( World.inputs, data )

                        Component.Velocity data ->
                            acc &=> ( World.velocities, data )

                        Component.Camera (Camera.Follow data) ->
                            let
                                ( entityId, world_ ) =
                                    acc

                                camera =
                                    world_.camera

                                newWorld =
                                    entityId
                                        |> Maybe.map
                                            (\id ->
                                                { world_ | camera = { camera | behavior = Camera.Follow { data | id = id } } }
                                            )
                                        |> Maybe.withDefault world_
                            in
                            ( entityId, newWorld )

                        Component.Camera data ->
                            let
                                _ =
                                    Debug.log "IMPLEMENT logic for other type of cameras" data

                                -- Debug.log "Add camera parsing here!!!" world_.camera.behavior
                            in
                            acc
                )
                (Slime.forNewEntity world)
                entity
    in
    newWorld


componentTransform : (a -> Maybe b) -> List (List a) -> Maybe (List (List b))
componentTransform func data =
    traverse (traverse func) data


traverse : (a -> Maybe b) -> List a -> Maybe (List b)
traverse f =
    -- Maybe.Extra.traverse
    let
        step e acc =
            case f e of
                Nothing ->
                    Nothing

                Just x ->
                    Maybe.map ((::) x) acc
    in
    List.foldr step (Just [])
