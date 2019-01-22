module Logic.GameFlow exposing (GameFlow(..), Model, update)


type alias Model a =
    { a
        | frame : Int
        , runtime_ : Float
        , flow : GameFlow --Running -- SlowMotion { frames = 60, fps = 20 }
    }


type GameFlow
    = Running
    | Pause
    | SlowMotion { frames : Int, fps : Int }


default : { fps : Float }
default =
    { fps = 60 }


update : (Model a -> Model a) -> Float -> Model a -> Model a
update systems delta world =
    let
        ( worldWithUpdatedRuntime, countOfFrames ) =
            case world.flow of
                Running ->
                    updateRuntime world delta default.fps

                Pause ->
                    updateRuntime world delta 0

                SlowMotion current ->
                    let
                        ( newWorld, countOfFrames_ ) =
                            updateRuntime world delta (toFloat current.fps)

                        framesLeft =
                            current.frames - countOfFrames_

                        ( flow, runtime ) =
                            if framesLeft < 0 then
                                ( Running, newWorld.frame |> resetRuntime default.fps )

                            else
                                ( SlowMotion { current | frames = framesLeft }, newWorld.runtime_ )
                    in
                    ( { newWorld | flow = flow, runtime_ = runtime }, countOfFrames_ )
    in
    worldWithUpdatedRuntime
        |> (if countOfFrames > 0 then
                worldUpdate systems countOfFrames

            else
                identity
           )


resetRuntime : Float -> Int -> Float
resetRuntime fps frames =
    toFloat frames / fps


updateRuntime : Model a -> Float -> Float -> ( Model a, Int )
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


worldUpdate : (Model a -> Model a) -> Int -> Model a -> Model a
worldUpdate system framesLeft world =
    if framesLeft < 1 then
        world

    else
        let
            newWorld =
                system world
        in
        worldUpdate system (framesLeft - 1) { newWorld | frame = newWorld.frame + 1 }
