module Logic.Template.Component.Physics exposing (World, empty, spec, system)

import Logic.Component.Singleton as Singleton
import Logic.System exposing (System)
import Physic.AABB


type alias World =
    Physic.AABB.World Int


spec : Singleton.Spec World { world | physics : World }
spec =
    { get = .physics
    , set = \comps world -> { world | physics = comps }
    }


system : Singleton.Spec World world -> System world
system spec_ =
    Singleton.update spec_ (Physic.AABB.simulate 1)


empty : World
empty =
    Physic.AABB.empty
