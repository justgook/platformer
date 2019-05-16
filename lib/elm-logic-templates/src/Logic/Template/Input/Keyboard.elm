module Logic.Template.Input.Keyboard exposing (sub)

import Array
import Browser.Events
import Dict
import Json.Decode as Decode
import Logic.Entity as Entity exposing (EntityID)
import Set exposing (Set)


sub spec world =
    Sub.batch
        [ Browser.Events.onKeyDown (onKeyDown spec world)
        , Browser.Events.onKeyUp (onKeyUp spec world)
        ]


onKeyDown spec world =
    let
        direction =
            spec.get world
    in
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered direction)
        |> Decode.andThen
            (\key ->
                Set.insert key direction.pressed
                    |> updateKeys spec key world
            )


onKeyUp spec world =
    let
        direction =
            spec.get world
    in
    Decode.field "key" Decode.string
        |> Decode.andThen (isRegistered direction)
        |> Decode.andThen
            (\key ->
                Set.remove key direction.pressed
                    |> updateKeys spec key world
            )


isRegistered direction key =
    --TODO maybe get rid of it and extend more updateKeys to fail in Maybe..
    if Dict.member key direction.registered then
        Decode.succeed key

    else
        Decode.fail "not registered key"


updateKeys { get, set } keyChanged world pressed =
    let
        direction =
            get world
    in
    if direction.pressed == pressed then
        Decode.fail "Nothing change"

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
        Decode.succeed (set { updatedDirection | pressed = pressed } world)


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
