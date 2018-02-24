module Game.Logic.System exposing (collision, control, gravity, inputListener, movement, runtime)

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
    --     var rect1 = {x: 5, y: 5, width: 50, height: 50}
    -- var rect2 = {x: 20, y: 10, width: 10, height: 10}
    -- if (rect1.x < rect2.x + rect2.width &&
    --    rect1.x + rect1.width > rect2.x &&
    --    rect1.y < rect2.y + rect2.height &&
    --    rect1.height + rect1.y > rect2.y) {
    --     // collision detected!
    -- }
    -- I suggest computing the Minkowski sum of B and A, which is a new rectangle, and checking where the centre of A lies relatively to the diagonals of that rectangle:
    -- float wy = (A.width() + B.width()) * (A.centerY() - B.centerY());
    -- float hx = (A.height() + B.height()) * (A.centerX() - B.centerX());
    -- if (wy > hx)
    --     if (wy > -hx)
    --         /* top */
    --     else
    --         /* left */
    -- else
    --     if (wy > -hx)
    --         /* right */
    --     else
    --         /* bottom */
    world
        |> Slime.stepEntities (Slime.entities2 World.collisions World.boundingBoxes)
            (\({ a, b } as ent2) ->
                if
                    --TODO add 1px on each side - to intersect when it not touches.. or round that part..
                    QuadTree.findIntersecting ent2.b world.boundingBoxes |> Array.length |> (<) 1
                then
                    { ent2 | a = { a | bottom = True } }
                else
                    { ent2 | a = { a | bottom = False } }
            )


runtime : Time -> World -> World
runtime delta world =
    { world | runtime = world.runtime + delta }


gravity : Time -> World -> World
gravity delta world =
    let
        updateVelocity { bottom } velocity =
            if not bottom then
                { velocity | vy = world.gravity }
            else
                { velocity | vy = 0 }
    in
    Slime.stepEntities (Slime.entities2 World.collisions World.velocities)
        (\({ a, b } as ent2) -> { ent2 | b = updateVelocity a b })
        world


movement : Time -> World -> World
movement delta =
    let
        addVelocity velocity position delta =
            { position
                | x = position.x + velocity.vx * delta
                , y = position.y + velocity.vy * delta
            }

        addVelocity2 velocity ({ boundingBox } as data) delta =
            let
                ( x, y ) =
                    ( boundingBox.horizontal.low + velocity.vx * delta
                    , boundingBox.vertical.low + velocity.vy * delta
                    )
            in
            { data
                | boundingBox =
                    { horizontal =
                        { low = x
                        , high = boundingBox.horizontal.high - boundingBox.horizontal.low + x
                        }
                    , vertical =
                        { low = y
                        , high = boundingBox.vertical.high - boundingBox.vertical.low + y
                        }
                    }
            }
    in
    Slime.stepEntities (Slime.entities2 World.velocities World.boundingBoxes)
        (\ent2 ->
            { ent2
                | b = addVelocity2 ent2.a ent2.b delta
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

                -- _ =
                --     Debug.log "Speed" result
            in
            { ent2 | b = { b | vx = result, vy = ent2.b.vy + toFloat ent2.a.y } }
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
