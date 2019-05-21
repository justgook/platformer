module Logic.Template.Component.Physics exposing (World, empty, spec)

import Logic.Component.Singleton exposing (Spec)
import Physic.AABB


type alias World =
    Physic.AABB.World Int


spec : Spec World { world | physics : World }
spec =
    { get = .physics
    , set = \comps world -> { world | physics = comps }
    }


empty : World
empty =
    Physic.AABB.empty
