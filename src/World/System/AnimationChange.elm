module World.System.AnimationChange exposing (sideScroll)

import Dict
import Direction as Dir
import Logic.Entity
import Logic.System as System
import Physic.AABB
import Physic.Narrow.AABB
import World.Component.Sprite exposing (Sprite(..))


sideScroll physicsSpec objSpec animSpec ( common, ecs ) =
    let
        engine =
            physicsSpec.get ecs

        physicsComps =
            engine |> Physic.AABB.getIndexed |> Logic.Entity.fromList

        ( _, newEcs ) =
            System.step3
                (\( body, _ ) ( obj_, setObj ) ( ( ( name, dir_ ) as current, anim ), setAnim ) acc ->
                    let
                        velocity =
                            Physic.Narrow.AABB.getVelocity body

                        contact =
                            Physic.Narrow.AABB.getContact body

                        dir =
                            { velocity | y = 0 } |> Dir.fromRecord |> Dir.toInt

                        key =
                            if velocity.y > 0 then
                                ( "jump", nonZero dir dir_ )

                            else if velocity.y < 0 then
                                ( "fall", nonZero dir dir_ )

                            else if contact.y == -1 then
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
                            ( Animated obj, Just a ) ->
                                let
                                    _ =
                                        ( Physic.Narrow.AABB.getPosition body, ( current, key, contact.y ) )
                                            |> Debug.log "AnimationChange"
                                in
                                acc
                                    |> setObj
                                        (Animated
                                            { obj
                                                | tileSet = a.tileSet
                                                , tileSetSize = a.tileSetSize
                                                , tileSize = a.tileSize
                                                , mirror = a.mirror
                                                , animLUT = a.animLUT
                                                , animLength = a.animLength
                                                , start = common.frame |> toFloat
                                            }
                                        )
                                    |> setAnim ( key, anim )

                            _ ->
                                acc
                )
                delmeSpecFirst
                (delmeSpecSecond objSpec)
                (delmeSpecSecond animSpec)
                (delmeCreate physicsComps ecs)
    in
    ( common, newEcs )


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
