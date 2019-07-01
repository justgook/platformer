module Logic.GameFlow exposing (GameFlow(..), update, Model, updateWith, ExtendedModel)

{-|

@docs GameFlow, update, Model, updateWith, ExtendedModel

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
3.  `SlowMotion { frames = 60, fps = 20 }` - will run game **20FPS** for next **60** frames (3s)

-}
type GameFlow
    = Running
    | Pause
    | SlowMotion { frames : Int, fps : Int }


default : { fps : Float }
default =
    { fps = 60 }


{-| -}
type alias ExtendedModel a b =
    ( Model a, b )


{-| same as update, but instead of Model, takes tuple, to make same output as default Elm update function
-}
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


{-| -}
update : (Model a -> Model a) -> Float -> Model a -> Model a
update systems delta model =
    let
        ( worldWithUpdatedRuntime, countOfFrames ) =
            case model.flow of
                Running ->
                    updateRuntime_ model delta default.fps

                Pause ->
                    updateRuntime_ model delta 0

                SlowMotion current ->
                    let
                        ( newWorld, countOfFrames_ ) =
                            updateRuntime_ model delta (toFloat current.fps)

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
                worldUpdate_ systems countOfFrames

            else
                identity
           )


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


updateRuntime_ : Model a -> Float -> Float -> ( Model a, Int )
updateRuntime_ model delta fps =
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


worldUpdate : (ExtendedModel a b -> ExtendedModel a b) -> Int -> ExtendedModel a b -> ExtendedModel a b
worldUpdate system framesLeft model =
    if framesLeft < 1 then
        model

    else
        let
            ( newWorld, newWorld2 ) =
                system model
        in
        worldUpdate system (framesLeft - 1) ( { newWorld | frame = newWorld.frame + 1 }, newWorld2 )


worldUpdate_ : (Model a -> Model a) -> Int -> Model a -> Model a
worldUpdate_ system framesLeft model =
    if framesLeft < 1 then
        model

    else
        let
            newModel =
                system model
        in
        worldUpdate_ system (framesLeft - 1) { newModel | frame = newModel.frame + 1 }
