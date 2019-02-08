module World.Component exposing (Object(..), defaultRead, dimensions, inFirst, objects, positions)

import Array exposing (Array)
import Defaults exposing (default)
import Dict.Any as Dict
import Layer.Common as Common
import Layer.Object.Ellipse
import Layer.Object.Rectangle
import Layer.Object.Tile
import Logic.Component exposing (Set, Spec, first, second)
import Logic.Entity as Entity exposing (EntityID)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector4 exposing (Vec4, vec4)
import Tiled.Object as Object exposing (Common, Dimension, Gid, PolyPoints)


type Object
    = Static
    | Rectangle (Common.Individual Layer.Object.Rectangle.Model)
    | Ellipse (Common.Individual Layer.Object.Ellipse.Model)
    | Tile (Common.Individual Layer.Object.Tile.Model)


type alias ExtendedSpec comp world layer =
    { spec : Spec comp world
    , read : Read world layer
    , empty : Logic.Component.Set comp
    }



-- World.Component.Return world (Set Object)


type alias Return world layer =
    ( world -> ( EntityID, world ), layer -> ( EntityID, layer ) )
    -> ( world -> ( EntityID, world ), layer -> ( EntityID, layer ) )


type alias Read world layer =
    { objectTile : Common -> Dimension -> Gid -> Return world layer
    , objectPoint : Common -> Return world layer
    , objectRectangle : Common -> Dimension -> Return world layer
    , objectEllipse : Common -> Dimension -> Return world layer
    , objectPolygon : Common -> Dimension -> PolyPoints -> Return world layer
    , objectPolyLine : Common -> Dimension -> PolyPoints -> Return world layer
    }


defaultRead : Read world layer
defaultRead =
    { objectTile = \_ _ _ a -> a
    , objectPoint = \_ a -> a
    , objectRectangle = \_ _ a -> a
    , objectEllipse = \_ _ a -> a
    , objectPolygon = \_ _ _ a -> a
    , objectPolyLine = \_ _ _ a -> a
    }



-- objects : RenderSpec z world (Set Object)


objects =
    --TODO create other for isometric view
    let
        spec =
            { get = identity
            , set = \comps _ -> comps
            }
    in
    { spec = spec
    , read =
        { defaultRead
            | objectTile =
                \{ x, y } _ _ ->
                    inSecond (Entity.with ( spec, Rectangle delme ))
        }
    }


delme =
    { x = 106
    , y = 30
    , width = 16
    , height = 16
    , color = vec4 1 0 1 1
    , scrollRatio = vec2 1 1
    , transparentcolor = default.transparentcolor
    }


positions : ExtendedSpec Vec2 { a | positions : Set Vec2 } layer
positions =
    --TODO create other for isometric view
    let
        spec =
            { get = .positions
            , set = \comps world -> { world | positions = comps }
            }
    in
    { spec = spec
    , empty = Array.empty
    , read =
        { defaultRead
            | objectTile =
                \{ x, y } _ _ ->
                    inFirst (Entity.with ( spec, vec2 x y ))
        }
    }


dimensions : ExtendedSpec Vec2 { a | dimensions : Set Vec2 } layer
dimensions =
    let
        spec =
            { get = .dimensions
            , set = \comps world -> { world | dimensions = comps }
            }
    in
    { spec = spec
    , empty = Array.empty
    , read =
        { defaultRead
            | objectTile =
                \_ { height, width } _ ->
                    inFirst (Entity.with ( spec, vec2 width height ))
        }
    }


inFirst f ( acc1, acc2 ) =
    ( acc1 >> f, acc2 )


inSecond f ( acc1, acc2 ) =
    ( acc1, acc2 >> f )



-- Entity.with ( position, vec2 21 21 )
-- Entity.with ( spec dimensions, vec2 common.x common.y )
-- Just (vec2 common.x common.y)
-- defaultRead =
--     { objectLayer = \layer -> []
--     , objectTile = \common dimension gid -> []
--     }
-- positionsExtractor =
--     { tile = () }
-- positions =
--     { get = .positions
--     , set = \comps world -> { world | positions = comps }
--     }
-- objects =
--     { get = identity
--     , set = \comps _ -> comps
--     }
-- dimensions =
--     { get = .dimensions
--     , set = \comps world -> { world | dimensions = comps }
--     }
-- velocities =
--     { get = .velocities
--     , set = \comps world -> { world | velocities = comps }
--     }
-- animations =
--     { get = .animations2
--     , set = \comps world -> { world | animations2 = comps }
--     }
