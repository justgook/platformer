module Game.ECS.System exposing (collision, control, gravity, inputListener, movement)

-- import Game.ECS.Component exposing (Ball, Paddle, Position, Rect, Velocity)
-- import Keyboard exposing (KeyCode)

import Game.ECS.Component exposing (Dimension(Rectangle))
import Game.ECS.Message exposing (Message)
import Game.ECS.World as World exposing (World)
import Keyboard.Extra
import Slime
import Time exposing (Time)


collision : World -> World
collision world =
    let
        -- https://developer.mozilla.org/kab/docs/Games/Techniques/2D_collision_detection
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
        collide rect1 rect2 =
            (rect1.x + rect1.width > rect2.x)
                && (rect1.x < rect2.x + rect2.width)
                && (rect1.y + rect1.height > rect2.y)
                && (rect1.y < rect2.y + rect2.height)

        test =
            world
                |> (Slime.entities2 World.positions World.dimensions).getter
                |> List.map
                    (\{ a, b, id } ->
                        let
                            (Rectangle { width, height }) =
                                b
                        in
                        { id = id, x = a.x, y = a.y, width = width, height = height }
                    )
    in
    world
        |> Slime.stepEntities (Slime.entities3 World.collisions World.positions World.dimensions)
            (\({ a, b, c, id } as ent3) ->
                let
                    (Rectangle { width, height }) =
                        c
                in
                if
                    List.any
                        (\i ->
                            (i.id /= id)
                                && collide i { x = b.x, y = b.y, width = width, height = height }
                        )
                        test
                then
                    { ent3 | a = { a | bottom = True } }
                else
                    { ent3 | a = { a | bottom = False } }
            )



-- https://developer.mozilla.org/kab/docs/Games/Techniques/2D_collision_detection
-- https://gamedev.stackexchange.com/a/29796


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
    in
    Slime.stepEntities (Slime.entities2 World.velocities World.positions)
        (\ent2 -> { ent2 | b = addVelocity ent2.a ent2.b delta })


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

                _ =
                    Debug.log "Speed" result
            in
            { ent2 | b = { b | vx = result, vy = ent2.b.vy + toFloat ent2.a.y } }
        )


inputListener : Message -> World -> World
inputListener (Game.ECS.Message.Input msg) world =
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
