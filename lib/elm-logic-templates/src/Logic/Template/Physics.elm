module Logic.Template.Physics exposing (World, empty, spec)

--physics : EcsSpec { a | dimensions : Logic.Component.Set Vec2 } Vec2 (Logic.Component.Set Vec2)

import Physic.AABB


type alias World =
    Physic.AABB.World Int


spec =
    { get = .physics
    , set = \comps world -> { world | physics = comps }
    }


empty =
    Physic.AABB.empty
