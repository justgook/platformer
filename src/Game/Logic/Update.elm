module Game.Logic.Update exposing (update)

import Game.Logic.Engine exposing (engine)
import Game.Logic.Message as Message exposing (Message)
import Game.Logic.World as World exposing (World)
import Slime.Engine


defaultFPS : Float
defaultFPS =
    60


update : Slime.Engine.Message Message -> World -> ( World, Cmd (Slime.Engine.Message Message) )
update msg_ world =
    case msg_ of
        Slime.Engine.Tick delta ->
            let
                ( worldWithUpdatedRuntime, countOfFrames ) =
                    case world.flow of
                        World.Running ->
                            updateRuntime world delta defaultFPS

                        World.Pause ->
                            updateRuntime world delta 0

                        World.SlowMotion current ->
                            let
                                ( newWorld, countOfFrames_ ) =
                                    updateRuntime world delta (toFloat current.fps)

                                framesLeft =
                                    current.frames - countOfFrames_

                                ( flow, runtime ) =
                                    if framesLeft < 0 then
                                        ( World.Running, newWorld.frame |> resetRuntime defaultFPS )
                                    else
                                        ( World.SlowMotion { current | frames = framesLeft }, newWorld.runtime_ )
                            in
                                ( { newWorld | flow = flow, runtime_ = runtime }, countOfFrames_ )
            in
                if countOfFrames > 0 then
                    updaterFunc
                        (flip (Slime.Engine.applySystems engine) delta)
                        countOfFrames
                        ( worldWithUpdatedRuntime, Cmd.none )
                        |> Tuple.mapSecond (Cmd.map Slime.Engine.Msg)
                else
                    ( worldWithUpdatedRuntime, Cmd.none )

        Slime.Engine.Msg (Message.Exception Message.Pause) ->
            let
                ( flow, runtime ) =
                    case world.flow of
                        World.Pause ->
                            ( World.Running, world.frame |> resetRuntime defaultFPS )

                        _ ->
                            ( World.Pause, world.runtime_ )
            in
                ( { world | flow = flow, runtime_ = runtime }
                , Cmd.none
                )

        Slime.Engine.Msg (Message.Exception msg) ->
            let
                _ =
                    Debug.log "Slime.Engine.Msg Message.Exception" msg
            in
                ( world
                , Cmd.none
                )

        Slime.Engine.Msg msg ->
            let
                ( updatedWorld, commands ) =
                    Slime.Engine.applyListeners engine world msg
            in
                ( updatedWorld
                , Cmd.map Slime.Engine.Msg commands
                )

        Slime.Engine.Noop ->
            ( world
            , Cmd.none
            )


resetRuntime : Float -> Int -> Float
resetRuntime fps frames =
    toFloat frames / fps


updateRuntime : { a | frame : Int, runtime_ : Float } -> Float -> Float -> ( { a | frame : Int, runtime_ : Float }, Int )
updateRuntime world delta fps =
    let
        thresholdTime =
            1 / fps * 12

        deltaSec =
            delta / 1000

        newRuntime =
            -- max 12 game frame per one animationFrame event
            world.runtime_ + min deltaSec thresholdTime

        countOfFrames =
            (newRuntime * fps - toFloat world.frame)
                |> min (fps * thresholdTime)
                |> round
    in
        ( { world | runtime_ = newRuntime }, countOfFrames )


updaterFunc : (World -> ( World, Cmd Message )) -> Int -> ( World, Cmd Message ) -> ( World, Cmd Message )
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
