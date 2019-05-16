module Logic.Template.TiledRead.Internal.Reader exposing
    ( GetTileset
    , Read(..)
    , Reader
    , combine
    , defaultRead
    , tileArgs
    , tileDataWith
    )

import Logic.Entity exposing (EntityID)
import Logic.Template.TiledRead.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Tiled exposing (GidInfo)
import Tiled.Layer
import Tiled.Level
import Tiled.Object exposing (Common, CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints, Dimension, Gid, PolyPoints)
import Tiled.Properties
import Tiled.Tileset exposing (Tileset)


type alias Reader world =
    { objectTile : Read world TileArg
    , objectPoint : Read world (Common {})
    , objectRectangle : Read world CommonDimension
    , objectEllipse : Read world CommonDimension
    , objectPolygon : Read world CommonDimensionPolyPoints
    , objectPolyLine : Read world CommonDimensionPolyPoints
    , layerTile : Read world TileDataWith
    , layerImage : Read world Tiled.Layer.ImageData
    , level : Read world Tiled.Level.Level
    }


type alias GetTileset =
    Int -> CacheTask -> ResourceTask Tileset


type alias ReturnSync world =
    ( EntityID, world ) -> ( EntityID, world )


type alias ReturnAsync world =
    CacheTask -> ResourceTask (( EntityID, world ) -> ( EntityID, world ))


type Read world a
    = Sync (a -> ReturnSync world)
    | Async (a -> ReturnAsync world)
    | None


defaultRead : Reader world
defaultRead =
    { objectTile = None
    , objectPoint = None
    , objectRectangle = None
    , objectEllipse = None
    , objectPolygon = None
    , objectPolyLine = None
    , layerTile = None
    , layerImage = None
    , level = None
    }


type alias TileArg =
    { fd : Bool
    , fh : Bool
    , fv : Bool
    , getTilesetByGid : GetTileset
    , gid : Int
    , height : Float
    , id : Int
    , kind : String
    , name : String
    , properties : Tiled.Properties.Properties
    , rotation : Float
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    }


type alias TileDataWith =
    { getTilesetByGid : GetTileset
    , id : Int
    , data : List Int
    , name : String
    , opacity : Float
    , visible : Bool
    , width : Int
    , height : Int
    , x : Float
    , y : Float
    , properties : Tiled.Properties.Properties
    }


tileDataWith : GetTileset -> Tiled.Layer.TileData -> TileDataWith
tileDataWith getTilesetByGid tileData =
    { getTilesetByGid = getTilesetByGid
    , id = tileData.id
    , data = tileData.data
    , name = tileData.name
    , opacity = tileData.opacity
    , visible = tileData.visible
    , width = tileData.width
    , height = tileData.height
    , x = tileData.x
    , y = tileData.y
    , properties = tileData.properties
    }


tileArgs : CommonDimensionGid -> GidInfo -> GetTileset -> TileArg
tileArgs a c d =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = a.width
    , height = a.height
    , getTilesetByGid = d
    , gid = c.gid
    , fh = c.fh
    , fv = c.fv
    , fd = c.fd
    }


combine :
    (reader -> Read world a)
    -> a
    -> List reader
    -> ( EntityID, world )
    -> CacheTask
    -> ResourceTask ( EntityID, world )
combine getKey arg readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None ->
                    combine getKey arg rest acc

                Sync f ->
                    combine getKey arg rest (f arg acc)

                Async f ->
                    f arg >> ResourceTask.andThen (\f1 -> combine getKey arg rest (f1 acc))

        [] ->
            ResourceTask.succeed acc
