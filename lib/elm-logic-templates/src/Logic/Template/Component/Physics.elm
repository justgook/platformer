module Logic.Template.Component.Physics exposing (World, empty, spec, system)

import Collision.Physic.AABB
import Logic.Component.Singleton as Singleton
import Logic.System exposing (System)


type alias World =
    Collision.Physic.AABB.World Int


spec : Singleton.Spec World { world | physics : World }
spec =
    { get = .physics
    , set = \comps world -> { world | physics = comps }
    }


system : Singleton.Spec World world -> System world
system spec_ =
    Singleton.update spec_ (Collision.Physic.AABB.simulate 1)


empty : World
empty =
    Collision.Physic.AABB.empty
