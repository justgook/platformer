module Game.Logic.System
    exposing
        ( animationsChanger
        , camera
        , collision
        , gravity
        , inputListener
        , jump
        , rightLeft
        )

import Game.Logic.Camera.Model as Camera
import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape as Collision exposing (Shape)
import Game.Logic.Component as Component
import Game.Logic.Message as Message exposing (Message)
import Game.Logic.World as World exposing (World)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Slime
import Task


camera : World -> World
camera world =
    let
        camera =
            case world.camera.behavior of
                Camera.Follow { id } ->
                    Slime.getComponent world.collisions id
                        |> Maybe.map (Collision.position >> flip Camera.setCenter world.camera)
                        |> Maybe.withDefault world.camera

                data ->
                    let
                        _ =
                            Debug.log "System for camera not implemented"
                    in
                    world.camera

        -- , viewportOffset = vec2 ((toFloat world.frame / 60) * 75) (cos (toFloat world.frame / 60) * 5)
        -- , viewportOffset = vec2 (sin (toFloat world.frame / 60) * 16) (cos (toFloat world.frame / 60) * 16)
    in
    { world | camera = camera }


gravity : World -> World
gravity world =
    Slime.stepEntities (Slime.entities World.velocities)
        (\({ a } as ent) -> { ent | a = Vec2.add a world.gravity })
        world


jump : World -> World
jump world =
    Slime.stepEntities (Slime.entities3 World.velocities World.inputs World.collisions)
        (\({ a, b, c } as ent) ->
            let
                ( x, y ) =
                    Vec2.toTuple a

                collision =
                    c.response |> Vec2.toRecord

                --TODO make it based on props of character
                jumpImpulse =
                    15

                newVelY =
                    if collision.y > 0 && b.y > 0 && y == 0 then
                        jumpImpulse
                    else
                        y
            in
            { ent | a = vec2 x newVelY }
        )
        world


rightLeft : World -> World
rightLeft world =
    Slime.stepEntities (Slime.entities2 World.velocities World.inputs)
        (\({ a, b } as ent) ->
            let
                ( x, y ) =
                    Vec2.toTuple a

                --TODO make it based on props of character
                moveSpeed =
                    3

                newVelX =
                    --TODO find if there is real collision
                    if b.x > 0 then
                        moveSpeed
                    else if b.x < 0 then
                        -moveSpeed
                    else
                        0
            in
            { ent | a = vec2 newVelX y }
        )
        world


collision : World -> World
collision world =
    Slime.stepEntities (Slime.entities2 World.collisions World.velocities)
        (\ent ->
            let
                shape =
                    ent.a

                velocity =
                    ent.b

                updatedShape =
                    response3 velocity shape world.collisionMap

                pos1 =
                    Collision.position shape
                        |> Vec2.toRecord

                pos2 =
                    Collision.position updatedShape
                        |> Vec2.toRecord

                newVel =
                    if pos1.y == pos2.y then
                        Vec2.setY 0 velocity
                    else
                        velocity
            in
            { ent
                | a = updatedShape
                , b = newVel
            }
        )
        world


response3 : Vec2 -> Component.CollisionData -> World.CollisionMap -> Component.CollisionData
response3 vel shape collisionMap =
    let
        distance =
            Vec2.length vel
    in
    if distance == 0 then
        shape
    else
        let
            _ =
                Collision.cellSize collisionMap

            setpSize =
                Collision.stepSize collisionMap

            samplingCount =
                distance / setpSize

            normal =
                Vec2.normalize vel

            result =
                sampler3
                    (stepFunc3 collisionMap)
                    normal
                    setpSize
                    samplingCount
                    shape
        in
        if result /= shape then
            result
        else
            shape


sampler3 : (Vec2 -> Component.CollisionData -> Component.CollisionData) -> Vec2 -> Float -> Float -> Component.CollisionData -> Component.CollisionData
sampler3 stepFunc normal setpSize distance shape =
    if distance > 1 then
        stepFunc (Vec2.scale (1 * setpSize) normal) shape
            |> sampler3 stepFunc normal setpSize (distance - 1)
    else
        stepFunc (Vec2.scale (distance * setpSize) normal) shape


stepFunc3 : World.CollisionMap -> Vec2 -> Component.CollisionData -> Component.CollisionData
stepFunc3 collisionMap vec_ shape_ =
    let
        newShape =
            Collision.updatePosition vec_ shape_

        inter =
            Collision.intersection newShape collisionMap

        result =
            if List.length inter > 0 then
                List.foldl collisionFolder3 newShape inter
            else
                newShape

        newResponse =
            Collision.position newShape
                |> Vec2.sub (Collision.position result)
    in
    { result | response = newResponse }


collisionFolder3 : Collision.WithShape a -> Component.CollisionData -> Component.CollisionData
collisionFolder3 tile acc =
    let
        result =
            Collision.response tile acc
                |> Maybe.map (flip Collision.updatePosition acc)
                |> Maybe.withDefault acc
    in
    result



-- inputListener : Message -> World -> World


pauseGame : List a -> List a -> a -> Bool
pauseGame oldKeys newKeys key =
    not (List.member key oldKeys) && List.member key newKeys


inputListener : Message -> World -> ( World, Cmd Message )
inputListener income world =
    --Add Touch events for virtual gamepad
    case income of
        Message.Input msg ->
            let
                updatedWorld =
                    { world | pressedKeys = Keyboard.Extra.update msg world.pressedKeys }

                updateInputs a keys =
                    let
                        { x, y } =
                            a.parse keys
                    in
                    { a | x = x, y = y }

                --TODO find better solution
                cmd =
                    if pauseGame world.pressedKeys updatedWorld.pressedKeys Keyboard.Extra.Escape then
                        Message.Exception Message.Pause |> send
                    else
                        Cmd.none
            in
            ( Slime.stepEntities (Slime.entities World.inputs)
                (\ent -> { ent | a = updateInputs ent.a updatedWorld.pressedKeys })
                updatedWorld
            , cmd
            )

        _ ->
            ( world, Cmd.none )


send : msg -> Cmd msg
send msg =
    --TODO Find better way How to pass that to the top
    Task.succeed msg
        |> Task.perform identity


maxMove : Vec2 -> Vec2 -> Vec2
maxMove a b =
    let
        ( ( x1, y1 ), ( x2, y2 ) ) =
            ( Vec2.toTuple a, Vec2.toTuple b )
    in
    vec2 (absMax x1 x2) (absMax y1 y2)


absMax : Float -> Float -> Float
absMax x y =
    if abs x > abs y then
        x
    else
        y


absMaxVec2 : Vec2 -> Vec2 -> Vec2
absMaxVec2 a b =
    if Vec2.length a > Vec2.length b then
        a
    else
        b



-- updageCollisions : Collision.WithShape a -> Maybe Vec2 -> Collision.WithShape a
-- updageCollisions newShape vec =
--     Maybe.map (flip Collision.updatePosition newShape) vec
--         |> Maybe.withDefault newShape


animationsChanger : World -> World
animationsChanger world =
    Slime.stepEntities (Slime.entities3 World.animations World.characterAnimations World.inputs)
        (\({ a, b, c } as reuslt) ->
            let
                newAnim =
                    if c.x > 0 then
                        b.right
                    else if c.x < 0 then
                        b.left
                    else
                        b.stand

                -- getComponent : ComponentSet a -> EntityID -> Maybe a
            in
            if ( newAnim.lut, newAnim.mirror ) /= ( a.lut, a.mirror ) then
                { reuslt | a = { newAnim | started = world.frame } }
            else
                reuslt
        )
        world
