module World.Component.Common exposing
    ( EcsSpec
    , Read
    , Return
    , defaultRead
    )

import Error exposing (Error)
import Logic.Component
import Logic.Entity exposing (EntityID)
import Task exposing (Task)
import Tiled.Object exposing (Common, Dimension, Gid, PolyPoints)
import World.Create exposing (GetImageData)


type alias EcsSpec esc comp empty =
    { spec : Logic.Component.Spec comp esc
    , read : Read esc
    , empty : empty
    }


type alias Return world =
    ( EntityID, world ) -> Task Error ( EntityID, world )


type alias Read world =
    { objectTile : GetImageData -> Common -> Dimension -> Gid -> Return world
    , objectTileRenderable : GetImageData -> Common -> Dimension -> Gid -> Return world
    , objectPoint : Common -> Return world
    , objectRectangle : Common -> Dimension -> Return world
    , objectEllipse : Common -> Dimension -> Return world
    , objectPolygon : Common -> Dimension -> PolyPoints -> Return world
    , objectPolyLine : Common -> Dimension -> PolyPoints -> Return world
    }


defaultRead : Read world
defaultRead =
    { objectTile = \_ _ _ _ a -> Task.succeed a
    , objectTileRenderable = \_ _ _ _ a -> Task.succeed a
    , objectPoint = \_ a -> Task.succeed a
    , objectRectangle = \_ _ a -> Task.succeed a
    , objectEllipse = \_ _ a -> Task.succeed a
    , objectPolygon = \_ _ _ a -> Task.succeed a
    , objectPolyLine = \_ _ _ a -> Task.succeed a
    }
