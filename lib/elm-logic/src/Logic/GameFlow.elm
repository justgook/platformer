module Logic.GameFlow exposing
    ( GameFlow(..), update, Model, updateWith, ExtendedModel
    , setFrameRate
    )

{-|

@docs GameFlow, update, Model, updateWith, ExtendedModel
@docs setFrameRate

-}


{-| Extendable Model to run inside update
-}
type alias Model a =
    { a
        | frame : Int
        , runtime_ : Float
        , flow : GameFlow --Running -- SlowMotion { frames = 60, fps = 20 }
    }


{-| game flow for update function

1.  `Running` - runs in normal way 60FPS
2.  `Pause` - game is stopped, and no `Systems` is running
3.  `SlowMotion { frames = 30, fps = 20 }` - will run game **20FPS** for next **30** frames (1.5s) and then return to normal flow (`Running`)

-}
type GameFlow
    = Running
    | Pause
    | SlowMotion { endTime : Float, fps : Int }


{-| Reduce or increase game FPS for limited amount of time, useful for creating freeze frame, or debugging some systems frame by frame
-}
setFrameRate : { a | time : Float, fps : Int } -> Model world -> Model world
setFrameRate { time, fps } w =
    let
        runtime =
            w.frame
                |> resetRuntime (toFloat fps)
    in
    { w
        | runtime_ = runtime
        , flow = SlowMotion { endTime = runtime + time, fps = fps }
    }


defaultFps : Float
defaultFps =
    60


{-| -}
type alias ExtendedModel a b =
    ( Model a, b )


{-| same as `update`, but instead of World, it takes tuple, to make same output as default TEA `update` function
-}
updateWith : (ExtendedModel a b -> ExtendedModel a b) -> Float -> ExtendedModel a b -> ExtendedModel a b
updateWith systems delta (( world, _ ) as model) =
    let
        ( worldWithUpdatedRuntime, countOfFrames ) =
            case world.flow of
                Running ->
                    updateRuntimeExtended model delta defaultFps

                Pause ->
                    updateRuntimeExtended model delta 0

                SlowMotion current ->
                    let
                        ( ( newWorld, newWorld2 ), countOfFrames_ ) =
                            updateRuntimeExtended model delta (toFloat current.fps)

                        ( flow, runtime ) =
                            if current.endTime <= world.runtime_ then
                                ( Running, newWorld.frame |> resetRuntime defaultFps )

                            else
                                ( world.flow, newWorld.runtime_ )
                    in
                    ( ( { newWorld | flow = flow, runtime_ = runtime }, newWorld2 ), countOfFrames_ )
    in
    worldWithUpdatedRuntime
        |> (if countOfFrames > 0 then
                worldUpdateExtended systems countOfFrames

            else
                identity
           )


{-| -}
update : (Model a -> Model a) -> Float -> Model a -> Model a
update systems delta model =
    let
        ( worldWithUpdatedRuntime, countOfFrames ) =
            case model.flow of
                Running ->
                    updateRuntime model delta defaultFps

                Pause ->
                    updateRuntime model delta 0

                SlowMotion current ->
                    let
                        ( newWorld, countOfFrames_ ) =
                            updateRuntime model delta (toFloat current.fps)

                        ( flow, runtime ) =
                            if current.endTime <= model.runtime_ then
                                ( Running, newWorld.frame |> resetRuntime defaultFps )

                            else
                                ( model.flow, newWorld.runtime_ )
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
    if fps > 0 then
        toFloat frames / fps

    else
        0


updateRuntimeExtended : ExtendedModel a b -> Float -> Float -> ( ExtendedModel a b, Int )
updateRuntimeExtended ( world, world2 ) delta fps =
    let
        ( w1, countOfFrames ) =
            updateRuntime world delta fps
    in
    ( ( w1, world2 ), countOfFrames )


updateRuntime : Model a -> Float -> Float -> ( Model a, Int )
updateRuntime model delta fps =
    let
        thresholdTime =
            1 / fps * 12

        deltaSec =
            delta / 1000

        newRuntime =
            -- max 12 game frame per one animationFrame event
            model.runtime_ + min deltaSec thresholdTime

        countOfFrames =
            (newRuntime * fps - toFloat model.frame)
                |> min (fps * thresholdTime)
                |> round
    in
    ( { model | runtime_ = newRuntime }, countOfFrames )


worldUpdateExtended : (ExtendedModel a b -> ExtendedModel a b) -> Int -> ExtendedModel a b -> ExtendedModel a b
worldUpdateExtended system framesLeft model =
    if framesLeft < 1 then
        model

    else
        let
            ( newWorld, newWorld2 ) =
                system model
        in
        worldUpdateExtended system (framesLeft - 1) ( { newWorld | frame = newWorld.frame + 1 }, newWorld2 )


worldUpdate : (Model a -> Model a) -> Int -> Model a -> Model a
worldUpdate system framesLeft model =
    if framesLeft < 1 then
        model

    else
        let
            newModel =
                system model
        in
        worldUpdate system (framesLeft - 1) { newModel | frame = newModel.frame + 1 }
