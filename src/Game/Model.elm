module Game.Model exposing (Level, LoaderData(..), Model, RenderData(..), WaitingLayers(..), init)

-- import RemoteData exposing (WebData)

import Game.Logic.World as World exposing (World)
import Game.TextureLoader as TextureLoader
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Util.Level exposing (Layer, LevelWith, Tileset)
import Util.Level.Special as Level exposing (LevelProps)
import WebGL


type alias Model =
    { level : Level
    , widthRatio : Float
    , textures : TextureLoader.Model
    , world : World
    , renderData : LoaderData String (List WaitingLayers) (List RenderData)
    }


init : Model
init =
    { level = Level.init
    , textures = TextureLoader.init
    , widthRatio = 1
    , world = World.init
    , renderData = NotAsked
    }


type alias Level =
    --TODO delete when all is parsed no need to store that data when game is running
    LevelWith LevelProps Layer Tileset


type RenderData
    = ImageLayerRenderData { texture : WebGL.Texture, x : Float, y : Float }
    | TileLayerRenderData
        { lutTexture : WebGL.Texture
        , lutSize : Vec2
        , tileSetTexture : WebGL.Texture
        , tileSetSize : Vec2
        , transparentcolor : Vec3
        , tileSize : Vec2
        }
    | ActionLayerRenderData


type LoaderData error loadingData resultData
    = NotAsked
    | Loading loadingData
    | Failure error
    | Success resultData


type WaitingLayers
    = WaitingImageLayer { texture : String, x : Float, y : Float }
    | WaitingActionLayer
    | WaitingTileLayer1
        --TODO add suport for textures with multiple tilesets
        { lutTexture : String
        , lutSize : Vec2
        , tileSetTexture : String
        , tileSetSize : Vec2
        , transparentcolor : Vec3
        , tileSize : Vec2
        }



-- all : List (RemoteData.RemoteData e a) -> RemoteData.RemoteData e (List a)
-- all remoteDatas =
--     List.foldr (RemoteData.map2 (::)) (RemoteData.succeed []) remoteDatas
-- add : RemoteData e a -> RemoteData e (List a) -> RemoteData e (List a)
-- add remoteItem remoteItems =
--     RemoteData.map2 (\x xs -> xs ++ [ x ]) remoteItem remoteItems
