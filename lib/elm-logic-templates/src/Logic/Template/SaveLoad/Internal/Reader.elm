module Logic.Template.SaveLoad.Internal.Reader exposing
    ( EllipseData
    , ExtractAsync
    , GuardReader
    , Read(..)
    , Reader
    , RectangleData
    , TileArg
    , TileDataWith
    , WorldRead
    , WorldReader
    , andThen
    , combine
    , combineListInTask
    , defaultRead
    , guard
    , pointData
    , polygonData
    , rectangleData
    , tileArgs
    , tileDataWith
    )

import Logic.Entity exposing (EntityID)
import Logic.Launcher exposing (Error(..))
import Logic.Template.SaveLoad.Internal.Loader as Loader exposing (CacheTiled(..), GetTileset)
import Logic.Template.SaveLoad.Internal.ResourceTask as ResourceTask exposing (CacheTask, ResourceTask)
import Tiled exposing (GidInfo)
import Tiled.Layer exposing (TileChunkedData)
import Tiled.Level
import Tiled.Object exposing (Common, CommonDimension, CommonDimensionGid, CommonDimensionPolyPoints, Dimension, Gid, PolyPoints)
import Tiled.Properties


type alias WorldReader world =
    Reader (( EntityID, world ) -> ( EntityID, world ))


type alias GuardReader =
    Reader Bool


type alias Reader to =
    { objectTile : Read TileArg to
    , objectPoint : Read PointData to
    , objectRectangle : Read RectangleData to
    , objectEllipse : Read EllipseData to
    , objectPolygon : Read PolygonData to
    , objectPolyLine : Read PolyLineData to
    , layerTile : Read TileDataWith to
    , layerInfiniteTile : Read TileChunkedData to
    , layerImage : Read Tiled.Layer.ImageData to
    , layerObject : Read Tiled.Layer.ObjectData to
    , level : Read Tiled.Level.Level to
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


type alias ExtractAsync from to =
    from -> CacheTask CacheTiled -> ResourceTask to CacheTiled


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


type alias WorldRead from world =
    Read from (( EntityID, world ) -> ( EntityID, world ))


type Read from to
    = Sync (from -> to)
    | Async (from -> Loader.TaskTiled to)
    | None


andThen : (a -> WorldReader world) -> Reader a -> WorldReader world
andThen doThen r =
    let
        resultToAsync f1 input result =
            case f1 result of
                Sync f ->
                    ResourceTask.succeed (f input)

                Async f ->
                    f input

                None ->
                    ResourceTask.succeed identity

        change a f1 =
            case a of
                Sync f2 ->
                    Async
                        (\input ->
                            f2 input |> resultToAsync f1 input
                        )

                Async f2 ->
                    Async
                        (\input ->
                            f2 input >> ResourceTask.andThen (resultToAsync f1 input)
                        )

                None ->
                    None
    in
    { objectTile = change r.objectTile (doThen >> .objectTile)
    , objectPoint = change r.objectPoint (doThen >> .objectPoint)
    , objectRectangle = change r.objectRectangle (doThen >> .objectRectangle)
    , objectEllipse = change r.objectEllipse (doThen >> .objectEllipse)
    , objectPolygon = change r.objectPolygon (doThen >> .objectPolygon)
    , objectPolyLine = change r.objectPolyLine (doThen >> .objectPolyLine)
    , layerTile = change r.layerTile (doThen >> .layerTile)
    , layerInfiniteTile = change r.layerInfiniteTile (doThen >> .layerInfiniteTile)
    , layerImage = change r.layerImage (doThen >> .layerImage)
    , layerObject = change r.layerObject (doThen >> .layerObject)
    , level = change r.level (doThen >> .level)
    }


guard : GuardReader -> WorldReader world -> WorldReader world
guard g r =
    let
        change a b =
            case ( a, b ) of
                ( _, None ) ->
                    None

                ( None, _ ) ->
                    b

                ( Sync f, Sync f2 ) ->
                    Sync
                        (\input ->
                            if f input then
                                f2 input

                            else
                                identity
                        )

                ( Sync f, Async f2 ) ->
                    Async
                        (\input ->
                            if f input then
                                f2 input

                            else
                                ResourceTask.succeed identity
                        )

                ( Async f, Async f2 ) ->
                    Async
                        (\input ->
                            f input
                                >> ResourceTask.andThen
                                    (\result ->
                                        if result then
                                            f2 input

                                        else
                                            ResourceTask.succeed identity
                                    )
                        )

                ( Async f, Sync f2 ) ->
                    Async
                        (\input ->
                            f input
                                >> ResourceTask.andThen
                                    (\result ->
                                        if result then
                                            ResourceTask.succeed (f2 input)

                                        else
                                            ResourceTask.succeed identity
                                    )
                        )
    in
    { objectTile = change g.objectTile r.objectTile
    , objectPoint = change g.objectPoint r.objectPoint
    , objectRectangle = change g.objectRectangle r.objectRectangle
    , objectEllipse = change g.objectEllipse r.objectEllipse
    , objectPolygon = change g.objectPolygon r.objectPolygon
    , objectPolyLine = change g.objectPolyLine r.objectPolyLine
    , layerTile = change g.layerTile r.layerTile
    , layerInfiniteTile = change g.layerInfiniteTile r.layerInfiniteTile
    , layerImage = change g.layerImage r.layerImage
    , layerObject = change g.layerObject r.layerObject
    , level = change g.level r.level
    }


defaultRead : Reader to
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
    , level : Tiled.Level.Level
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


tileArgs : Tiled.Level.Level -> Tiled.Layer.ObjectData -> CommonDimensionGid -> GidInfo -> GetTileset -> TileArg
tileArgs level objectData a c d =
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
    , level = level
    }


combine : WorldReader world -> WorldReader world -> WorldReader world
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


combine_ : (WorldReader world -> WorldRead a world) -> WorldReader world -> WorldReader world -> WorldRead a world
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
    (reader -> WorldRead a world)
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
