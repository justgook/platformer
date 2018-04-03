module Game.Logic.System
    exposing
        ( animationsChanger
        , inputListener
        , movement
        )

import Game.Logic.Collision.Map as Collision
import Game.Logic.Collision.Shape as Collision exposing (Shape)
import Game.Logic.Message exposing (Message)
import Game.Logic.World as World exposing (World)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Slime


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


movement : World -> World
movement world =
    Slime.stepEntities (Slime.entities2 World.collisions World.inputs)
        (\ent2 ->
            let
                shape =
                    ent2.a

                input =
                    ent2.b

                pixelsPerFrame =
                    1

                movePost =
                    vec2 (toFloat input.x * pixelsPerFrame) (toFloat input.y * pixelsPerFrame)

                newShape =
                    Collision.updatePosition movePost shape

                _ =
                    Collision.intersection shape world.collisionMap
                        -- |> List.length
                        |> Debug.log "movement::intersection"

                -- _ =
                --     (1 / 0)
                --         == (1 / 0)
                --         |> Debug.log "Inf"
                -- |> Maybe.map Collision.updatePosition newShape
                --
            in
            { ent2 | a = newShape }
        )
        world


updageCollisions : Shape -> Maybe Vec2 -> Shape
updageCollisions newShape vec =
    vec
        |> Maybe.map (flip Collision.updatePosition newShape)
        |> Maybe.withDefault newShape
