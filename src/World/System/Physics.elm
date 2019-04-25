module World.System.Physics exposing (aabb, applyInput, body)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Logic.Entity
import Logic.System
import Physic
import Physic.AABB
import Physic.Narrow.AABB as AABB


body { get, set } ( common, ecs ) =
    ( common, set (Physic.update 1 (get ecs)) ecs )


aabb { get, set } ( common, ecs ) =
    ( common, set (Physic.AABB.simulate 1 (get ecs)) ecs )


applyInput force inputSpec physicsSpec ( common, ecs ) =
    let
        engine =
            physicsSpec.get ecs

        physicsComps =
            engine |> Physic.AABB.getIndexed |> Logic.Entity.fromList

        ( updatedPhysicsComps, _ ) =
            Logic.System.step2
                (\( body_, setBody ) ( key, _ ) acc ->
                    case ( key.x, key.y == 1 ) of
                        ( a, True ) ->
                            if .y (AABB.getContact body_) == -1 then
                                setBody (AABB.setVelocity (vec2 (key.x * force.x) force.y) body_) acc

                            else if a == 0 then
                                setBody (AABB.updateVelocity (\v -> { v | x = 0 }) body_) acc

                            else
                                setBody (AABB.updateVelocity (\v -> { v | x = key.x * force.x }) body_) acc

                        ( a, False ) ->
                            if a == 0 then
                                setBody (AABB.updateVelocity (\v -> { v | x = 0 }) body_) acc

                            else
                                setBody (AABB.updateVelocity (\v -> { v | x = key.x * force.x }) body_) acc
                )
                bindSpecFirst
                (bindSpecSecond inputSpec)
                (bindCreate physicsComps ecs)
    in
    ( common
    , ecs |> physicsSpec.set { engine | indexed = updatedPhysicsComps |> Logic.Entity.toDict }
    )


bindSpecFirst =
    { get = Tuple.first
    , set = \comps ( a, b ) -> ( comps, b )
    }


bindSpecSecond spec =
    { get = Tuple.second >> spec.get
    , set = \comps ( a, world ) -> ( a, spec.set comps world )
    }


bindCreate a world =
    ( a, world )
