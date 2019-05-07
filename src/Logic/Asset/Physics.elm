module Logic.Asset.Physics exposing (World, empty, spec)

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



--aabbPhysicsWith spec =
--    let
--        updateConfig_ f info =
--            Physic.AABB.setConfig (f (Physic.AABB.getConfig info)) info
--    in
--    common_ Physic.AABB.clear updateConfig_ createEnvAABB createDynamicAABB AABB.withIndex Physic.AABB.addBody spec
--
--createEnvAABB
--createDynamicAABB
--AABB.withIndex Physic.AABB.addBody spec
