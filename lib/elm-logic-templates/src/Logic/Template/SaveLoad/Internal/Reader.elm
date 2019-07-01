module Logic.Template.SaveLoad.Internal.Reader exposing
    ( EllipseData
    , Read(..)
    , Reader
    , RectangleData
    , TileArg
    , TileDataWith
    , combine
    , combineListInTask
    , defaultRead
    , pointData
    , polygonData
    , rectangleData
    , tileArgs
    , tileDataWith
    )

import Logic.Entity exposing (EntityID)
import Logic.Template.SaveLoad.Internal.Loader as Loader exposing (CacheTiled(..), GetTileset)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Tiled exposing (GidInfo)
import Tiled.Layer exposing (TileChunkedData)
import Tiled.Level
import Tiled.Object exposing (Common, CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints, Dimension, Gid, PolyPoints)
import Tiled.Properties


type alias Reader world =
    { objectTile : Read world TileArg
    , objectPoint : Read world PointData
    , objectRectangle : Read world RectangleData
    , objectEllipse : Read world EllipseData
    , objectPolygon : Read world PolygonData
    , objectPolyLine : Read world PolyLineData
    , layerTile : Read world TileDataWith
    , layerInfiniteTile : Read world TileChunkedData
    , layerImage : Read world Tiled.Layer.ImageData
    , layerObject : Read world Tiled.Layer.ObjectData
    , level : Read world Tiled.Level.Level
    }


type alias PointData =
    Common { layer : Tiled.Layer.ObjectData }


type alias RectangleData =
    Common (Dimension { layer : Tiled.Layer.ObjectData })


type alias EllipseData =
    RectangleData


type alias PolygonData =
    Common
        (Dimension
            { points : List { x : Float, y : Float }
            , layer : Tiled.Layer.ObjectData
            }
        )


type alias PolyLineData =
    PolygonData


pointData : Tiled.Layer.ObjectData -> Common {} -> PointData
pointData layer a =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , layer = layer
    }


rectangleData : Tiled.Layer.ObjectData -> CommonDimension -> RectangleData
rectangleData layer a =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , width = a.width
    , height = a.height
    , rotation = a.rotation
    , properties = a.properties
    , layer = layer
    }


polygonData : Tiled.Layer.ObjectData -> CommonDimensionPolyPoints -> PolygonData
polygonData layer a =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , width = a.width
    , height = a.height
    , rotation = a.rotation
    , properties = a.properties
    , points = a.points
    , layer = layer
    }


type alias ReturnSync world =
    ( EntityID, world ) -> ( EntityID, world )


type alias ReturnAsync world =
    Loader.TaskTiled (( EntityID, world ) -> ( EntityID, world ))


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
    , layerInfiniteTile = None
    , layerImage = None
    , layerObject = None
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
    , layer : Tiled.Layer.ObjectData
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


tileArgs : Tiled.Layer.ObjectData -> CommonDimensionGid -> GidInfo -> GetTileset -> TileArg
tileArgs objectData a c d =
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
    , layer = objectData
    }


combine : Reader world -> Reader world -> Reader world
combine r1 r2 =
    { objectTile = combine_ .objectTile r1 r2
    , objectPoint = combine_ .objectPoint r1 r2
    , objectRectangle = combine_ .objectRectangle r1 r2
    , objectEllipse = combine_ .objectEllipse r1 r2
    , objectPolygon = combine_ .objectPolygon r1 r2
    , objectPolyLine = combine_ .objectPolyLine r1 r2
    , layerTile = combine_ .layerTile r1 r2
    , layerInfiniteTile = combine_ .layerInfiniteTile r1 r2
    , layerImage = combine_ .layerImage r1 r2
    , layerObject = combine_ .layerObject r1 r2
    , level = combine_ .level r1 r2
    }


combine_ : (Reader world -> Read world a) -> Reader world -> Reader world -> Read world a
combine_ getKey r1 r2 =
    case ( getKey r1, getKey r2 ) of
        ( None, None ) ->
            None

        ( Sync f1, Sync f2 ) ->
            Sync (\a b -> f1 a b |> f2 a)

        ( Async f1, Sync f2 ) ->
            Async
                (\a b ->
                    f1 a b
                        |> ResourceTask.map (\_ d -> f2 a d)
                )

        ( Async f1, Async f2 ) ->
            Async
                (\a b ->
                    f1 a b
                        |> ResourceTask.andThen (\_ d -> f2 a d)
                )

        ( Sync f1, Async f2 ) ->
            Async
                (\a b ->
                    ResourceTask.succeed (f1 a) b
                        |> ResourceTask.andThen (\_ d -> f2 a d)
                )

        ( f1, None ) ->
            f1

        ( None, f2 ) ->
            f2


combineListInTask :
    (reader -> Read world a)
    -> a
    -> List reader
    -> ( EntityID, world )
    -> CacheTask CacheTiled
    -> ResourceTask ( EntityID, world ) CacheTiled
combineListInTask getKey arg readers acc =
    case readers of
        item :: rest ->
            case getKey item of
                None ->
                    combineListInTask getKey arg rest acc

                Sync f ->
                    combineListInTask getKey arg rest (f arg acc)

                Async f ->
                    f arg >> ResourceTask.andThen (\f1 -> combineListInTask getKey arg rest (f1 acc))

        [] ->
            ResourceTask.succeed acc
