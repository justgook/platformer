module World.Component.Common exposing
    ( EcsSpec
    , Read1(..)
    , Read2(..)
    , Read3(..)
    , Reader
    , defaultRead
    )

import Logic.Component
import Logic.Entity exposing (EntityID)
import ResourceTask exposing (CacheTask, ResourceTask)
import Tiled.Object exposing (Common, Dimension, Gid, PolyPoints)


type alias EcsSpec esc layer comp empty =
    { spec : Logic.Component.Spec comp esc
    , read : Reader esc layer
    , empty : empty
    }


type alias ReturnSync world =
    ( EntityID, world ) -> ( EntityID, world )


type alias ReturnAsync world =
    CacheTask -> ResourceTask (( EntityID, world ) -> ( EntityID, world ))


type alias Reader world layer =
    { objectTile : Read3 world Common Dimension Gid
    , objectTileRenderable : Read3 layer Common Dimension Gid
    , objectPoint : Read1 world Common
    , objectRectangle : Read2 world Common Dimension
    , objectEllipse : Read2 world Common Dimension
    , objectPolygon : Read3 world Common Dimension PolyPoints
    , objectPolyLine : Read3 world Common Dimension PolyPoints
    }


type Read1 world a
    = Sync1 (a -> ReturnSync world)
    | Async1 (a -> ReturnAsync world)
    | None1


type Read2 world a b
    = Sync2 (a -> b -> ReturnSync world)
    | Async2 (a -> b -> ReturnAsync world)
    | None2


type Read3 world a b c
    = Sync3 (a -> b -> c -> ReturnSync world)
    | Async3 (a -> b -> c -> ReturnAsync world)
    | None3


defaultRead : Reader world layer
defaultRead =
    { objectTile = None3
    , objectTileRenderable = None3
    , objectPoint = None1
    , objectRectangle = None2
    , objectEllipse = None2
    , objectPolygon = None3
    , objectPolyLine = None3
    }
