module World.Component.Common exposing
    ( EcsSpec
    , GetTileset
    , Read(..)
    , Reader
    , commonDimensionArgs
    , commonDimensionPolyPointsArgs
    , defaultRead
    , tileArgs
    )

import Logic.Component
import Logic.Entity exposing (EntityID)
import ResourceTask exposing (CacheTask, ResourceTask)
import Tiled exposing (GidInfo)
import Tiled.Object exposing (Common, Dimension, Gid, PolyPoints)
import Tiled.Properties
import Tiled.Tileset exposing (Tileset)


type alias EcsSpec esc comp empty =
    { spec : Logic.Component.Spec comp esc
    , read : Reader esc
    , empty : empty
    }


type alias Reader world =
    { objectTile : Read world TileArg

    --    , objectTileRenderable : Read layer TileArg
    , objectPoint : Read world Common
    , objectRectangle : Read world CommonDimensionArg
    , objectEllipse : Read world CommonDimensionArg
    , objectPolygon : Read world CommonDimensionPolyPointsArg
    , objectPolyLine : Read world CommonDimensionPolyPointsArg
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

    --    , objectTileRenderable = None
    , objectPoint = None
    , objectRectangle = None
    , objectEllipse = None
    , objectPolygon = None
    , objectPolyLine = None
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


type alias CommonDimensionArg =
    { height : Float
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


type alias CommonDimensionPolyPointsArg =
    { height : Float
    , id : Int
    , kind : String
    , name : String
    , properties : Tiled.Properties.Properties
    , rotation : Float
    , visible : Bool
    , width : Float
    , x : Float
    , y : Float
    , points : List { x : Float, y : Float }
    }


commonDimensionArgs : Common -> Dimension -> CommonDimensionArg
commonDimensionArgs a b =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = b.width
    , height = b.height
    }


commonDimensionPolyPointsArgs : Common -> Dimension -> PolyPoints -> CommonDimensionPolyPointsArg
commonDimensionPolyPointsArgs a b c =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = b.width
    , height = b.height
    , points = c
    }


tileArgs : Common -> Dimension -> GidInfo -> GetTileset -> TileArg
tileArgs a b c d =
    { id = a.id
    , name = a.name
    , kind = a.kind
    , visible = a.visible
    , x = a.x
    , y = a.y
    , rotation = a.rotation
    , properties = a.properties
    , width = b.width
    , height = b.height
    , getTilesetByGid = d
    , gid = c.gid
    , fh = c.fh
    , fv = c.fv
    , fd = c.fd
    }
