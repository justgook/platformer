module World.System.Camera exposing (autoScroll, follow, followX)

import Logic.Component.Singleton
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import World exposing (WorldTuple)
import World.Component.Camera exposing (Camera)



--http://www.gamasutra.com/blogs/ItayKeren/20150511/243083/Scroll_Back_The_Theory_and_Practice_of_Cameras_in_SideScrollers.php


follow spec getPos ( common, ecs ) =
    let
        cam =
            spec.get ecs

        target =
            getPos cam.id ecs

        viewportOffset =
            Vec2.fromRecord
                { x = target.x - cam.pixelsPerUnit / 2 * common.env.widthRatio
                , y = target.y - cam.pixelsPerUnit / 2
                }

        --        _ =
        --            Debug.log "viewportOffset" viewportOffset
    in
    ( common, spec.set { cam | viewportOffset = viewportOffset } ecs )


followX spec getPos ( common, ecs ) =
    let
        cam =
            spec.get ecs

        target =
            getPos cam.id ecs
    in
    ( common, spec.set { cam | viewportOffset = Vec2.setX (target.x - cam.pixelsPerUnit / 2 * common.env.widthRatio) cam.viewportOffset } ecs )


autoScroll : Logic.Component.Singleton.Spec Camera world -> Vec2 -> Vec2 -> WorldTuple world -> WorldTuple world
autoScroll spec speed rand ( common, ecs ) =
    let
        camera =
            spec.get ecs

        rand_ =
            Vec2.scale (sin (toFloat common.frame / 30)) rand
                |> Vec2.sub (Vec2.scale (sin (toFloat (common.frame - 1) / 30)) rand)

        { x, y } =
            camera.viewportOffset
                |> Vec2.add speed
                |> Vec2.add rand_
                |> Vec2.toRecord

        newX =
            x
                |> round
                |> modBy 724200
                |> toFloat
    in
    ( common
    , spec.set { camera | viewportOffset = vec2 newX y } ecs
    )



--
--demo : Easing -> List Vec3 -> WorldTuple { world | camera : Camera } -> WorldTuple { world | camera : Camera }
--demo easing points_ ( common, ecs ) =
--    let
--        points =
--            NE.fromList points_
--                |> Maybe.withDefault
--                    (vec3 0 0 ecs.camera.pixelsPerUnit |> NE.fromElement)
--
--        speed =
--            60
--
--        now =
--            toFloat common.frame / speed
--
--        index =
--            floor now
--
--        current =
--            NE.get index points
--
--        value =
--            easing (now - toFloat index)
--
--        next =
--            NE.get (index + 1) points
--
--        { x, y, z } =
--            Vec3.sub next current
--                |> Vec3.scale value
--                |> Vec3.add current
--                |> Vec3.toRecord
--    in
--    ( common
--    , { ecs | camera = { pixelsPerUnit = z, viewportOffset = vec2 x y } }
--    )
