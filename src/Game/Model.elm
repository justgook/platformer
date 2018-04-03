module Game.Model exposing (Data(..), LoaderData(..), Model, Repeat(..), init, loadingToSuccess)

-- import RemoteData exposing (WebData)
-- import Util.Level.Special as Level exposing (LevelProps, SpecialLayer)
-- import Tiled.Decode exposing (Layer, LevelWith, Tileset)

import Game.Logic.Collision.Map exposing (Map)
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
        }


init : Model
init =
    { widthRatio = 1
    , renderData = NotAsked
    }


type LoaderData error loadingData resultData
    = NotAsked
    | Loading loadingData
    | Failure error
    | Success resultData


type alias WhileLoading =
    { data : List (Data String)
    , properties : WorldProperties
    , textures : TextureLoader.Model
    , collisionMap : Map
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

                                                Component.Input data ->
                                                    Just (Component.Input data)
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
                    Success
                        { data = data
                        , world = createWorld data properties collisionMap
                        }
                )
            |> Maybe.withDefault (Loading income)


createWorld : List (Data WebGL.Texture) -> WorldProperties -> Map -> World
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
    List.foldl
        (\comp ->
            case comp of
                Component.Animation data ->
                    flip (&=>) ( World.animations, data )

                Component.CharacterAnimation data ->
                    flip (&=>) ( World.characterAnimations, data )

                Component.Sprite data ->
                    flip (&=>) ( World.sprites, data )

                Component.Collision data ->
                    flip (&=>) ( World.collisions, data )

                Component.Input data ->
                    flip (&=>) ( World.inputs, data )
        )
        (Slime.forNewEntity world)
        entity
        |> Tuple.second


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
