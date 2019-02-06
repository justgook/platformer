module Logic.GameFlow exposing (GameFlow(..), Model, update, updateWith)


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


type alias ExtendedModel a b =
    ( Model a, b )


updateWith : (ExtendedModel a b -> ExtendedModel a b) -> Float -> ExtendedModel a b -> ExtendedModel a b
updateWith systems delta (( world, _ ) as model) =
    let
        ( worldWithUpdatedRuntime, countOfFrames ) =
            case world.flow of
                Running ->
                    updateRuntime model delta default.fps

                Pause ->
                    updateRuntime model delta 0

                SlowMotion current ->
                    let
                        ( ( newWorld, newWorld2 ), countOfFrames_ ) =
                            updateRuntime model delta (toFloat current.fps)

                        framesLeft =
                            current.frames - countOfFrames_

                        ( flow, runtime ) =
                            if framesLeft < 0 then
                                ( Running, newWorld.frame |> resetRuntime default.fps )

                            else
                                ( SlowMotion { current | frames = framesLeft }, newWorld.runtime_ )
                    in
                    ( ( { newWorld | flow = flow, runtime_ = runtime }, newWorld2 ), countOfFrames_ )
    in
    worldWithUpdatedRuntime
        |> (if countOfFrames > 0 then
                worldUpdate systems countOfFrames

            else
                identity
           )


update : (Model a -> Model a) -> Float -> Model a -> Model a
update systems delta model =
    updateWith (Tuple.mapFirst systems) delta ( model, () )
        |> Tuple.first


resetRuntime : Float -> Int -> Float
resetRuntime fps frames =
    toFloat frames / fps


updateRuntime : ExtendedModel a b -> Float -> Float -> ( ExtendedModel a b, Int )
updateRuntime ( world, world2 ) delta fps =
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
    ( ( { world | runtime_ = newRuntime }, world2 ), countOfFrames )


worldUpdate : (ExtendedModel a b -> ExtendedModel a b) -> Int -> ExtendedModel a b -> ExtendedModel a b
worldUpdate system framesLeft (( world, world2 ) as model) =
    if framesLeft < 1 then
        model

    else
        let
            ( newWorld, newWorld2 ) =
                system model
        in
        worldUpdate system (framesLeft - 1) ( { newWorld | frame = newWorld.frame + 1 }, newWorld2 )
