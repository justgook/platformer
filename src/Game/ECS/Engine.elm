module Game.ECS.Engine exposing (engine)

import Game.ECS.Message exposing (Message)
import Game.ECS.System as System
import Game.ECS.World as World exposing (World)
import Slime exposing ((&->))
import Slime.Engine


engine : Slime.Engine.Engine World Message
engine =
    let
        deletor =
            Slime.deleteEntity World.dimensions
                &-> World.positions

        systems =
            [ Slime.Engine.timedSystem System.control
            , Slime.Engine.untimedSystem System.collision
            , Slime.Engine.timedSystem System.gravity
            , Slime.Engine.timedSystem System.movement

            -- , untimedSystem keepBalls
            -- , systemWith { timing = untimed, options = deletes } scoreBalls
            -- , untimedSystem bounceBalls
            -- , timedSystem movePaddles
            -- , systemWith { timing = timed, options = deletes } updateScores
            ]

        listeners =
            [ Slime.Engine.listener System.inputListener
            ]
    in
    Slime.Engine.initEngine deletor systems listeners
