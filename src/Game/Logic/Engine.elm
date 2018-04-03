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
            Slime.deleteEntity World.sprites
                &-> World.animations
                &-> World.characterAnimations
                &-> World.collisions
                &-> World.inputs

        systems =
            [ -- , Slime.Engine.untimedSystem System.collision
              -- , Slime.Engine.timedSystem System.gravity
              -- , Slime.Engine.timedSystem System.control
              -- , Slime.Engine.timedSystem System.jumping
              Slime.Engine.untimedSystem System.movement
            , Slime.Engine.untimedSystem System.animationsChanger
            ]

        listeners =
            [ Slime.Engine.listener System.inputListener
            ]
    in
    Slime.Engine.initEngine deletor systems listeners
