module Game.Logic.Engine exposing (engine)

import Game.Logic.Message exposing (Message)
import Game.Logic.System as System
import Game.Logic.World as World exposing (World)
import Slime exposing ((&->))
import Slime.Engine


engine : Slime.Engine.Engine World Message
engine =
    let
        deletor =
            Slime.deleteEntity World.collisions
                &-> World.boundingBoxes

        systems =
            [ Slime.Engine.timedSystem System.runtime
            , Slime.Engine.timedSystem System.control
            , Slime.Engine.untimedSystem System.collision
            , Slime.Engine.timedSystem System.gravity
            , Slime.Engine.timedSystem System.movement
            ]

        listeners =
            [ Slime.Engine.listener System.inputListener
            ]
    in
    Slime.Engine.initEngine deletor systems listeners
