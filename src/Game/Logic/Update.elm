module Game.Logic.Update exposing (update)

import Game.Logic.Engine exposing (engine)
import Game.Logic.Message exposing (Message)
import Game.Logic.World exposing (World)
import Slime.Engine


update : Slime.Engine.Message Message -> World -> ( World, Cmd (Slime.Engine.Message Message) )
update msg world =
    case msg of
        Slime.Engine.Tick delta ->
            let
                deltaMs =
                    delta / 1000

                newRuntime =
                    -- max 12 game frame per one animationFrame event
                    world.runtime_ + min deltaMs 0.2

                countOfFrames =
                    (newRuntime * 60 - toFloat world.frame)
                        |> min 12

                newWorld =
                    { world | runtime_ = newRuntime }

                ( updatedWorld, commands ) =
                    updaterFunc (flip (Slime.Engine.applySystems engine) deltaMs) countOfFrames ( newWorld, Cmd.none )
            in
            ( updatedWorld
            , Cmd.map Slime.Engine.Msg commands
            )

        Slime.Engine.Msg msg ->
            let
                ( updatedWorld, commands ) =
                    Slime.Engine.applyListeners engine world msg
            in
            ( updatedWorld
            , Cmd.map Slime.Engine.Msg commands
            )


updaterFunc : (World -> ( World, Cmd Message )) -> Float -> ( World, Cmd Message ) -> ( World, Cmd Message )
updaterFunc customFunction count ( world, cmd ) =
    if count < 1 then
        ( world, cmd )
    else
        let
            ( newWorld, newCmd ) =
                customFunction world

            combinedCmd =
                Cmd.batch [ cmd, newCmd ]
        in
        updaterFunc customFunction (count - 1) ( { newWorld | frame = newWorld.frame + 1 }, combinedCmd )
