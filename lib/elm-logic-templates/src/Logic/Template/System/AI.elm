module Logic.Template.System.AI exposing (system)

--https://gamedevelopment.tutsplus.com/series/understanding-steering-behaviors--gamedev-12732
-- https://www.youtube.com/watch?v=oBJxLYIih7M

import AltMath.Vector2 as Vec2 exposing (vec2)
import Logic.System exposing (System)
import Logic.Template.Component.AI as AI
import Set


system inputSpec posSpec velSpec aiSpec w =
    Logic.System.step4
        (\( input, setInput ) ( pos, _ ) ( velocity, setVel ) ( ai, setAi ) acc ->
            let
                distance_ =
                    Vec2.distanceSquared ai.target.position pos

                ( targets_, velocity_, input_ ) =
                    if pointOnSegment pos (Vec2.add pos velocity) ai.target.position then
                        ( ai, Vec2.sub ai.target.position pos, input )

                    else if distance_ < 1 && ai.waiting > 0 then
                        let
                            targets__ =
                                { ai | waiting = ai.waiting - 1 }

                            velocity__ =
                                vec2 0 0
                        in
                        ( targets__, velocity__, input )

                    else if distance_ < 1 then
                        let
                            targets__ =
                                changeTarget ai

                            targetPos =
                                targets__.target.position

                            velocity__ =
                                Vec2.sub targetPos pos
                                    |> Vec2.scale targets__.target.invSteps
                        in
                        ( targets__, velocity__, { input | action = Set.fromList targets__.target.action } )

                    else
                        ( ai, velocity, input )
            in
            acc
                |> setVel velocity_
                |> setInput input_
                |> setAi targets_
        )
        inputSpec
        posSpec
        velSpec
        aiSpec
        w


pointOnSegment a_ b_ c_ =
    let
        a =
            Vec2.toRecord a_

        b =
            Vec2.toRecord b_

        c =
            Vec2.toRecord c_
    in
    ((c.x - a.x) * (c.x - b.x) + (c.y - a.y) * (c.y - b.y)) < 0


changeTarget targets =
    let
        setPos ({ position } as info) =
            { info
                | position =
                    position

                --                        |> Vec2.mul { x = scale.x, y = scale.y }
                --                        |> (\a -> Vec2.sub a { x = scale.x * 0.5, y = 0 })
            }
    in
    case targets.next of
        next :: rest ->
            { targets
                | target = setPos next
                , prev = next :: targets.prev
                , next = rest
                , waiting = next.wait
            }

        [] ->
            case List.reverse targets.prev of
                next :: rest ->
                    { targets
                        | target = setPos next
                        , prev = [ next ]
                        , next = rest
                        , waiting = next.wait
                    }

                [] ->
                    { targets
                        | target = AI.emptySpot
                        , prev = []
                        , next = []
                        , waiting = 0
                    }
