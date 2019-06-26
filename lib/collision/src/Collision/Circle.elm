module Collision.Circle exposing (Circle)

import AltMath.Vector2 exposing (Vec2)
import Array exposing (Array)
import Collision.Physic.Narrow.Common exposing (Generic)


{-| <https://www.topcoder.com/community/competitive-programming/tutorials/geometry-concepts-line-intersection-and-its-applications/#line_line_intersection>
<https://www.jasondavies.com/maps/circle-tree/>
-}



--
--type alias Circle a =
--    { r : Float
--    , p : Vec2
--    }


type Circle comparable
    = Circle (Generic comparable) {}


type alias World =
    { indexed : Array Int }
