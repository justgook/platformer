module Logic.Template.System.SlideStop exposing (SlideStops, applyInput)

import AltMath.Vector2 as Vec2 exposing (Vec2, vec2)
import Collision.Physic.AABB
import Collision.Physic.Narrow.AABB as AABB
import Logic.Component as Component
import Logic.Entity as Entity
import Logic.System


type alias SlideStops =
    { prev : List Vec2
    , target : Vec2
    , next : List Vec2
    }


applyInput inputSpec physicsSpec ({ slideStops } as ecs) =
    let
        engine =
            physicsSpec.get ecs

        ( newEngine, newSlideStops ) =
            Maybe.map2
                (\body key ->
                    let
                        distance_ =
                            Vec2.distanceSquared ecs.slideStops.target pos

                        ( slideStops_, distance ) =
                            if distance_ < 1 && key.x > 0 then
                                let
                                    slideStops__ =
                                        slideStops.next
                                            |> List.head
                                            |> Maybe.map
                                                (\next ->
                                                    { slideStops
                                                        | target = next
                                                        , prev = slideStops.target :: slideStops.prev
                                                        , next = List.drop 1 slideStops.next
                                                    }
                                                )
                                            |> Maybe.withDefault slideStops
                                in
                                ( slideStops__, Vec2.distanceSquared slideStops__.target pos )

                            else if distance_ < 1 && key.x < 0 then
                                let
                                    slideStops__ =
                                        slideStops.prev
                                            |> List.head
                                            |> Maybe.map
                                                (\prev ->
                                                    { slideStops
                                                        | target = prev
                                                        , prev = List.drop 1 slideStops.prev
                                                        , next = slideStops.target :: slideStops.next
                                                    }
                                                )
                                            |> Maybe.withDefault slideStops
                                in
                                ( slideStops__, Vec2.distanceSquared slideStops__.target pos )

                            else
                                ( ecs.slideStops, distance_ )

                        pos =
                            AABB.getPosition body

                        dir =
                            Vec2.direction slideStops_.target pos

                        newBody =
                            AABB.updateVelocity
                                (\v ->
                                    if distance < 1 then
                                        { x = 0, y = 0 }

                                    else if distance < Vec2.lengthSquared v then
                                        dir |> Vec2.scale (distance / Vec2.lengthSquared v)

                                    else
                                        dir
                                            |> Vec2.scale 0.3
                                            |> Vec2.add v
                                )
                                body
                    in
                    ( Collision.Physic.AABB.setById ecs.camera.id newBody engine, slideStops_ )
                )
                (Collision.Physic.AABB.byId ecs.camera.id engine)
                (inputSpec.get ecs |> Entity.getComponent ecs.camera.id)
                |> Maybe.withDefault ( engine, ecs.slideStops )

        newEcs =
            physicsSpec.set newEngine ecs
    in
    { newEcs | slideStops = newSlideStops }
