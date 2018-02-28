module Game.Logic.System exposing (collision, control, gravity, inputListener, jumping, movement, runtime)

import Array
import Game.Logic.Message exposing (Message)
import Game.Logic.World as World exposing (World)
import Keyboard.Extra
import QuadTree
import Slime
import Time exposing (Time)


collision : World -> World
collision world =
    -- https://developer.mozilla.org/kab/docs/Games/Techniques/2D_collision_detection
    -- https://gamedev.stackexchange.com/a/29796
    world
        |> Slime.stepEntities (Slime.entities2 World.collisions World.boundingBoxes)
            (\({ a, b } as ent2) ->
                let
                    -- https://ellie-app.com/q9NDyszHBa1/0
                    --collisionSide a b acc =
                    -- let
                    --     aLeft = a.center.x - a.width / 2
                    --     aRight = a.center.x + a.width / 2
                    --     aTop = a.center.y - a.height / 2
                    --     aBottom = a.center.y + a.height / 2
                    --     bLeft = b.center.x - b.width / 2
                    --     bRight = b.center.x + b.width / 2
                    --     bTop = b.center.y - b.height / 2
                    --     bBottom = b.center.y + b.height / 2
                    --     collidesOnTop =
                    --         aTop >= bTop && aTop < bBottom
                    --     collidesOnLeft =
                    --         aLeft >= bLeft && aLeft < bRight
                    --     collidesOnRight =
                    --         aRight <= bRight && aRight > bLeft
                    --     collidesOnBottom =
                    --         aBottom <= bBottom && aBottom > bTop
                    -- in
                    -- { acc
                    --     | top = collidesOnTop
                    --     , left = collidesOnLeft
                    --     , right = collidesOnRight
                    --     , bottom = collidesOnBottom
                    -- }
                    collisionSide a b acc =
                        let
                            centerA =
                                QuadTree.center a

                            centerB =
                                QuadTree.center b

                            wy =
                                (QuadTree.width a + QuadTree.width b) * (centerA.y - centerB.y)

                            hx =
                                (QuadTree.height a + QuadTree.height b) * (centerA.x - centerB.x)
                        in
                        if wy > hx then
                            if wy > -hx then
                                { acc | top = True }
                            else
                                { acc | left = True }
                        else if wy > -hx then
                            { acc | right = True }
                        else
                            { acc | bottom = True }
                in
                QuadTree.findIntersecting ent2.b world.boundingBoxes
                    |> Array.foldl
                        (\({ boundingBox } as box) acc ->
                            if ent2.b.boundingBox /= box.boundingBox then
                                collisionSide ent2.b.boundingBox boundingBox acc
                            else
                                acc
                        )
                        { top = False, right = False, bottom = False, left = False }
                    |> (\a -> { ent2 | a = a })
                    -- |> Debug.log "collision"
            )


runtime : Time -> World -> World
runtime delta world =
    { world | runtime = world.runtime + delta }


gravity : Time -> World -> World
gravity delta world =
    let
        updateVelocity { top, right, bottom, left } velocity =
            if not bottom then
                { velocity | vy = world.gravity }
            else
                { velocity | vy = 0 }
    in
    Slime.stepEntities (Slime.entities2 World.collisions World.velocities)
        (\({ a, b } as ent2) -> { ent2 | b = updateVelocity a b })
        world


jumping : Time -> World -> World
jumping delta world =
    let
        test =
            Slime.stepEntities (Slime.entities3 World.jumps World.velocities World.collisions)
                (\ent3 -> ent3)
                world
    in
    world


movement : Time -> World -> World
movement delta =
    let
        addVelocity velocity ({ boundingBox } as data) collision delta =
            let
                ( x, y ) =
                    ( boundingBox.horizontal.low + velocity.vx * delta
                    , boundingBox.vertical.low + velocity.vy * delta
                    )
            in
            { data
                | boundingBox =
                    { horizontal =
                        if
                            (x > boundingBox.horizontal.low && not collision.left)
                                || (x < boundingBox.horizontal.low && not collision.right)
                        then
                            { low = x
                            , high = boundingBox.horizontal.high - boundingBox.horizontal.low + x
                            }
                        else
                            boundingBox.horizontal
                    , vertical =
                        if
                            (y > boundingBox.vertical.low && not collision.bottom)
                                || (y < boundingBox.vertical.low && not collision.top)
                        then
                            { low = y
                            , high = boundingBox.vertical.high - boundingBox.vertical.low + y
                            }
                        else
                            boundingBox.vertical
                    }
            }
    in
    Slime.stepEntities (Slime.entities3 World.velocities World.boundingBoxes World.collisions)
        (\ent3 ->
            { ent3
                | b = addVelocity ent3.a ent3.b ent3.c delta
            }
        )


control : Time -> World -> World
control delta =
    Slime.stepEntities (Slime.entities2 World.inputs World.velocities)
        (\({ a, b } as ent2) ->
            let
                { x, y } =
                    a

                { vx, vy, speed, acc, maxSpeed } =
                    b

                --Move Stuff out to movement
                vx_ =
                    if (x > 0 && vx < 0) || (x < 0 && vx > 0) then
                        0
                    else
                        vx

                vy_ =
                    if y > 0 then
                        -100
                    else
                        vy

                curentSpeed =
                    if x /= 0 then
                        if abs vx_ < speed then
                            speed * x + vx_ + acc * delta * x
                        else
                            vx_ + acc * delta * x
                    else
                        0

                result =
                    if abs curentSpeed < maxSpeed then
                        curentSpeed
                    else
                        maxSpeed * x
            in
            { ent2 | b = { b | vx = result, vy = vy_ } }
        )


inputListener : Message -> World -> World
inputListener (Game.Logic.Message.Input msg) world =
    --Add Touch events for virtual gamepad
    let
        updatedWorld =
            { world | pressedKeys = Keyboard.Extra.update msg world.pressedKeys }

        updateInputs a keys =
            let
                { x, y } =
                    a.parse keys
            in
            { a | x = x, y = y }
    in
    Slime.stepEntities (Slime.entities World.inputs)
        (\ent -> { ent | a = updateInputs ent.a updatedWorld.pressedKeys })
        updatedWorld
