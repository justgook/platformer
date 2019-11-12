module Logic.Template.System.TimelineChange exposing (sideScroll, topDown)

import AltMath.Vector2
import Collision.Physic.AABB
import Collision.Physic.Narrow.AABB
import Dict
import Direction as Dir
import Logic.Entity
import Logic.System as System


topDown inputSpec animDictSpec timelineSpec ecs =
    System.step3
        (\( input, _ ) ( obj_, setObj ) ( ( current, anim ), setAnim ) acc ->
            let
                key =
                    ( "walk", { x = input.x, y = input.y } |> Dir.fromRecord |> Dir.toInt )
            in
            if key == current then
                acc

            else
                case ( obj_, Dict.get key anim ) of
                    ( obj, Just a ) ->
                        acc
                            |> setObj
                                { obj
                                    | timeline = a.timeline
                                    , uMirror = a.uMirror
                                    , start = ecs.frame
                                }
                            |> setAnim ( key, anim )

                    _ ->
                        acc
        )
        inputSpec
        timelineSpec
        animDictSpec
        ecs


sideScroll animSpec physicsSpec objSpec ecs =
    let
        engine =
            physicsSpec.get ecs

        physicsComps =
            engine |> Collision.Physic.AABB.getIndexed |> Logic.Entity.fromList

        ( _, newEcs ) =
            System.step3
                (\( body, _ ) ( obj_, setObj ) ( ( ( _, dir_ ) as current, anim ), setAnim ) acc ->
                    let
                        velocity =
                            Collision.Physic.Narrow.AABB.getVelocity body
                                |> AltMath.Vector2.toRecord

                        contactY =
                            Collision.Physic.Narrow.AABB.getContact body
                                |> AltMath.Vector2.getY

                        dir =
                            { velocity | y = 0 } |> Dir.fromRecord |> Dir.toInt

                        key =
                            if velocity.y > 0 then
                                ( "jump", nonZero dir dir_ )

                            else if velocity.y < 0 then
                                ( "fall", nonZero dir dir_ )

                            else if contactY == -1 then
                                if velocity.x == 0 then
                                    ( "idle", dir_ )

                                else
                                    ( "walk", { velocity | y = 0 } |> Dir.fromRecord |> Dir.toInt )

                            else
                                current
                    in
                    if key == current then
                        acc

                    else
                        case ( obj_, Dict.get key anim ) of
                            ( obj, Just a ) ->
                                acc
                                    |> setObj
                                        { obj
                                            | timeline = a.timeline
                                            , uMirror = a.uMirror
                                            , start = ecs.frame
                                        }
                                    |> setAnim ( key, anim )

                            _ ->
                                acc
                )
                delmeSpecFirst
                (delmeSpecSecond objSpec)
                (delmeSpecSecond animSpec)
                (delmeCreate physicsComps ecs)
    in
    newEcs


nonZero a b =
    if a == 0 then
        b

    else
        a


delmeSpecFirst =
    { get = Tuple.first
    , set = \comps ( a, b ) -> ( comps, b )
    }


delmeSpecSecond spec =
    { get = Tuple.second >> spec.get
    , set = \comps ( a, world ) -> ( a, spec.set comps world )
    }


delmeCreate a world =
    ( a, world )
