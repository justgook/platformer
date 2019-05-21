module World.System.Physics exposing (aabb, applyInput)

import AltMath.Vector2 as Vec2 exposing (vec2)
import Logic.Entity
import Logic.System
import Logic.Template.Input as Input
import Physic.AABB
import Physic.Narrow.AABB as AABB
import Set


aabb { get, set } ecs =
    set (Physic.AABB.simulate 1 (get ecs)) ecs


applyInput force inputSpec_ physicsSpec ecs =
    let
        engine =
            physicsSpec.get ecs

        physicsComps =
            engine |> Physic.AABB.getIndexed |> Logic.Entity.fromList

        inputSpec =
            Input.getComps inputSpec_

        ( updatedPhysicsComps, _ ) =
            Logic.System.step2
                (\( body_, setBody ) ( key, _ ) acc ->
                    case ( key.x, Set.member "Jump" key.action ) of
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
    physicsSpec.set { engine | indexed = updatedPhysicsComps |> Logic.Entity.toDict } ecs


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
