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
            [ Slime.Engine.untimedSystem System.gravity
            , Slime.Engine.untimedSystem System.collision
            , Slime.Engine.untimedSystem System.rightLeft
            , Slime.Engine.untimedSystem System.jump
            , Slime.Engine.untimedSystem System.animationsChanger
            , Slime.Engine.untimedSystem System.camera
            ]

        --
        -- systemWith { timing = untimed, options = deletes } scoreBalls
        listeners =
            [ -- Slime.Engine.listener System.inputListener
              Slime.Engine.listenerWith { options = Slime.Engine.cmds } System.inputListener
            ]
    in
        Slime.Engine.initEngine deletor systems listeners
