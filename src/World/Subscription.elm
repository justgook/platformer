module World.Subscription exposing (keyboard, portInput)

import Array
import Browser.Events
import Dict
import Json.Decode as Decode
import Logic.Entity as Entity exposing (EntityID)
import Set exposing (Set)


portInput ( gamepadDown, gamepadUp ) port_ world =
    --    https://github.com/jeromeetienne/virtualjoystick.js
    gamepadDown
        (\income ->
            let
                _ =
                    income
                        |> Decode.decodeValue Decode.string

                --                        |> Debug.log "gamePad msg"
            in
            world
        )


keyboard world =
    Sub.batch
        [ Browser.Events.onKeyDown (onKeyDown world)
        , Browser.Events.onKeyUp (onKeyUp world)
        ]


onKeyDown ({ direction } as world) =
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered direction)
        |> Decode.andThen
            (\key ->
                Set.insert key direction.pressed
                    |> updateKeys key world
            )


onKeyUp ({ direction } as world) =
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered direction)
        |> Decode.andThen
            (\key ->
                Set.remove key direction.pressed
                    |> updateKeys key world
            )


isRegistered direction key =
    --TODO maybe get rid of it and extend more updateKeys to fail in Maybe..
    if Dict.member key direction.registered then
        Decode.succeed key

    else
        Decode.fail "not registered key"


updateKeys keyChanged ({ direction } as world) pressed =
    if world.direction.pressed == pressed then
        Decode.fail "nothing chnaged"

    else
        let
            newComps =
                direction.registered
                    |> Dict.get keyChanged
                    |> Maybe.andThen
                        (\id ->
                            Array.get id direction.comps
                                |> Maybe.andThen identity
                                |> Maybe.map
                                    (\comp ->
                                        let
                                            { x, y } =
                                                arrows comp pressed
                                        in
                                        Entity.setComponent id { comp | x = x, y = y } direction.comps
                                    )
                        )
                    |> Maybe.withDefault direction.comps

            updatedDirection =
                { direction | comps = newComps }
        in
        Decode.succeed
            { world
                | direction =
                    { updatedDirection
                        | pressed = pressed
                    }
            }


arrows : { a | down : comparable, left : comparable, right : comparable, up : comparable } -> Set comparable -> { x : Float, y : Float }
arrows { up, right, down, left } keys =
    let
        x =
            keyToInt right keys - keyToInt left keys

        y =
            keyToInt up keys - keyToInt down keys
    in
    { x = x, y = y }


keyToInt : comparable -> Set comparable -> Float
keyToInt key =
    Set.member key >> boolToFloat


boolToFloat : Bool -> Float
boolToFloat bool =
    if bool then
        1

    else
        0
